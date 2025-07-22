class ContactMailer < ApplicationMailer
  def contact_form(contact_params)
    @name = contact_params[:name]
    @email = contact_params[:email]
    @phone = contact_params[:phone]
    @subject = contact_params[:subject]
    @message = contact_params[:message]

    mail(
      to: "lavruole@gmail.com",
      cc: "aktfrikshun@gmail.com",
      subject: "Contact Form: #{@subject} - #{@name}",
      reply_to: @email
    )
  end
end
