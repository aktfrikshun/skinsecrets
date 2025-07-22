class PagesController < ApplicationController
  def home
    @services = Service.active.limit(6)
    @featured_services = Service.active.where(featured: true).limit(3)
  end

  def about
  end

  def services
    @services = Service.active
  end

  def contact
  end

  def send_contact
    contact_params = params.permit(:name, :email, :phone, :subject, :message)

    # Basic validation
    if contact_params[:name].blank? || contact_params[:email].blank? || contact_params[:message].blank?
      redirect_to contact_path, alert: "Please fill in all required fields (name, email, and message)."
      return
    end

    # Send email
    begin
      EnveloopMailer.contact_form_notification(contact_params).deliver_now
      redirect_to contact_path, notice: "Thank you for your message! We'll get back to you within 24 hours."
    rescue => e
      Rails.logger.error "Contact form error: #{e.message}"
      redirect_to contact_path, alert: "Sorry, there was an error sending your message. Please try again or call us directly."
    end
  end
end
