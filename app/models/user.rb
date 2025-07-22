class User < ApplicationRecord
  has_secure_password

  has_many :appointments, dependent: :destroy
  has_many :forum_topics, dependent: :destroy
  has_many :forum_posts, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
