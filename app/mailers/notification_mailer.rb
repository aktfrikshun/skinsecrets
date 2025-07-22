class NotificationMailer < ApplicationMailer
  def appointment_confirmation(appointment)
    @appointment = appointment
    @user = appointment.user
    @service = appointment.service

    mail(
      to: @user.email,
      cc: [ "lavruole@gmail.com", "aktfrikshun@gmail.com" ],
      subject: "Appointment Confirmed - #{@service.name} on #{@appointment.formatted_date}"
    )
  end

  def new_appointment_notification(appointment)
    @appointment = appointment
    @user = appointment.user
    @service = appointment.service

    mail(
      to: [ "lavruole@gmail.com", "aktfrikshun@gmail.com" ],
      subject: "NEW APPOINTMENT BOOKED - #{@service.name} on #{@appointment.formatted_date}",
      reply_to: @user.email
    )
  end

  def appointment_reminder(appointment)
    @appointment = appointment
    @user = appointment.user
    @service = appointment.service

    mail(
      to: @user.email,
      subject: "Appointment Reminder - #{@service.name} tomorrow at #{@appointment.formatted_time}"
    )
  end

  def appointment_cancelled(appointment)
    @appointment = appointment
    @user = appointment.user
    @service = appointment.service

    mail(
      to: @user.email,
      cc: [ "lavruole@gmail.com", "aktfrikshun@gmail.com" ],
      subject: "Appointment Cancelled - #{@service.name} on #{@appointment.formatted_date}"
    )
  end

  def welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Welcome to Olga's Skin Secrets!"
    )
  end
end
