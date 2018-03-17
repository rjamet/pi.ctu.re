# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  balance                :integer          default(0), not null
#  fullname               :string
#  default_license        :string           default("CC BY-NC-ND"), not null
#  is_admin               :boolean          default(FALSE), not null
#  avatar                 :integer
#  avatar_filename        :string
#  customer_id            :string
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :invitation_token

  acts_as_voter

  mount_uploader :avatar, AvatarUploader

  has_many :albums
  has_many :pictures

  def remember_me
    true
  end

  def to_param
    username
  end

  def name
    fullname.presence || username
  end

  before_create do
    self.balance = 100e6 # Give 100 MB of data to each new user for free
  end

  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  validate :invitation_token_must_be_valid, on: :create

  def invitation_token_must_be_valid
    unless Invitation.approved.where(email: email, token: invitation_token).exists?
      errors.add(:invitation_token, "is invalid")
    end
  end
end
