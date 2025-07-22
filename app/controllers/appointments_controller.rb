class AppointmentsController < ApplicationController
  before_action :require_login
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy ]
  before_action :set_services, only: [ :new, :create, :edit, :update ]

  def index
    @appointments = @current_user.appointments.upcoming
  end

  def show
  end

  def new
    @appointment = @current_user.appointments.build
    @appointment.appointment_date = Date.current + 1.day
    @appointment.appointment_time = Time.current.beginning_of_hour + 1.hour
  end

  def create
    @appointment = @current_user.appointments.build(appointment_params)
    @appointment.status = "pending"

    if @appointment.save
      # Send confirmation email to customer (with CC to both addresses)
      EnveloopMailer.appointment_confirmation(@appointment).deliver_now

      # Send immediate notification to both email addresses
      EnveloopMailer.new_appointment_notification(@appointment).deliver_now

      redirect_to @appointment, notice: "Appointment booked successfully! Check your email for confirmation."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to @appointment, notice: "Appointment updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Send cancellation notification
    EnveloopMailer.appointment_cancelled(@appointment).deliver_now

    @appointment.destroy
    redirect_to appointments_path, notice: "Appointment cancelled successfully."
  end

  private

  def set_appointment
    @appointment = @current_user.appointments.find(params[:id])
  end

  def set_services
    @services = Service.active
  end

  def appointment_params
    params.require(:appointment).permit(:service_id, :appointment_date, :appointment_time, :notes)
  end
end
