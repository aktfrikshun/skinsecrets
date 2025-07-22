class Appointment < ApplicationRecord
  belongs_to :user
  belongs_to :service

  validates :appointment_date, presence: true
  validates :appointment_time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled completed] }

  scope :upcoming, -> { where("appointment_date >= ?", Date.current).order(:appointment_date, :appointment_time) }
  scope :past, -> { where("appointment_date < ?", Date.current).order(appointment_date: :desc, appointment_time: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :confirmed, -> { where(status: "confirmed") }

  def appointment_datetime
    DateTime.new(appointment_date.year, appointment_date.month, appointment_date.day,
                 appointment_time.hour, appointment_time.min, appointment_time.sec)
  end

  def formatted_date
    appointment_date.strftime("%B %d, %Y")
  end

  def formatted_time
    appointment_time.strftime("%I:%M %p")
  end

  def status_color
    case status
    when "pending"
      "yellow"
    when "confirmed"
      "green"
    when "cancelled"
      "red"
    when "completed"
      "blue"
    else
      "gray"
    end
  end
end
