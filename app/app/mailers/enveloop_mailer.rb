class EnveloopMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  def welcome_email(user)
    enveloop.send_message(
      template: "welcome-email",
      to: user.email,
      from: "akt@frikshun.com",
      subject: "Welcome to Olga's Skin Secrets!",
      template_variables: {
        user_name: user.full_name,
        account_url: "https://skin-secrets.fly.dev",
        services_url: "https://skin-secrets.fly.dev/services",
        booking_url: "https://skin-secrets.fly.dev/appointments/new"
      }
    )
  end

  def appointment_confirmation(appointment)
    enveloop.send_message(
      template: "appointment-confirmation",
      to: appointment.user.email,
      from: "akt@frikshun.com",
      subject: "Appointment Confirmation - #{appointment.service.name}",
      template_variables: {
        user_name: appointment.user.full_name,
        service_name: appointment.service.name,
        appointment_date: appointment.formatted_date,
        appointment_time: appointment.formatted_time,
        appointment_id: appointment.id,
        account_url: "https://skin-secrets.fly.dev"
      }
    )
  end

  def new_appointment_notification(appointment)
    # Send to primary email
    enveloop.send_message(
      template: "new-appointment-notification",
      to: "lavruole@gmail.com",
      from: "akt@frikshun.com",
      subject: "NEW APPOINTMENT BOOKED - #{appointment.service.name} on #{appointment.formatted_date}",
      template_variables: {
        customer_name: appointment.user.full_name,
        customer_email: appointment.user.email,
        service_name: appointment.service.name,
        appointment_date: appointment.formatted_date,
        appointment_time: appointment.formatted_time,
        appointment_notes: appointment.notes,
        appointment_id: appointment.id
      }
    )

    # Send to secondary email
    enveloop.send_message(
      template: "new-appointment-notification",
      to: "aktfrikshun@gmail.com",
      from: "akt@frikshun.com",
      subject: "NEW APPOINTMENT BOOKED - #{appointment.service.name} on #{appointment.formatted_date}",
      template_variables: {
        customer_name: appointment.user.full_name,
        customer_email: appointment.user.email,
        service_name: appointment.service.name,
        appointment_date: appointment.formatted_date,
        appointment_time: appointment.formatted_time,
        appointment_notes: appointment.notes,
        appointment_id: appointment.id
      }
    )
  end

  def appointment_cancelled(appointment)
    enveloop.send_message(
      template: "appointment-cancelled",
      to: appointment.user.email,
      from: "akt@frikshun.com",
      subject: "Appointment Cancelled - #{appointment.service.name}",
      template_variables: {
        user_name: appointment.user.full_name,
        service_name: appointment.service.name,
        appointment_date: appointment.formatted_date,
        appointment_time: appointment.formatted_time,
        booking_url: "https://skin-secrets.fly.dev/appointments/new"
      }
    )
  end

  def contact_form_notification(contact_params)
    # Send to primary email
    enveloop.send_message(
      template: "contact-form-notification",
      to: "lavruole@gmail.com",
      from: "akt@frikshun.comv",
      subject: "Contact Form: #{contact_params[:subject]} - #{contact_params[:name]}",
      template_variables: {
        name: contact_params[:name],
        email: contact_params[:email],
        phone: contact_params[:phone],
        subject: contact_params[:subject],
        message: contact_params[:message]
      }
    )

    # Send to secondary email
    enveloop.send_message(
      template: "contact-form-notification",
      to: "aktfrikshun@gmail.com",
      from: "akt@frikshun.com",
      subject: "Contact Form: #{contact_params[:subject]} - #{contact_params[:name]}",
      template_variables: {
        name: contact_params[:name],
        email: contact_params[:email],
        phone: contact_params[:phone],
        subject: contact_params[:subject],
        message: contact_params[:message]
      }
    )
  end

  private

  def enveloop
    @enveloop ||= Enveloop::Client.new(api_key: ENV["ENVELOOP_LIVE_API_KEY"])
  end
end
