class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable

  validates :email, presence: true, on: :create
  validates_uniqueness_of :email

  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  validates :password, confirmation: true, on: :create

end
