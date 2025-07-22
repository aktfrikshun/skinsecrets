class Service < ApplicationRecord
  has_many :appointments, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def formatted_price
    "$#{price}"
  end

  def formatted_duration
    "#{duration} minutes"
  end
end
