class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  has_many :questions_asked, class_name: 'Question', foreign_key: :user_id

  has_many :question_recipients
  has_many :questions_received, through: :question_recipients, source: :question

  def self.from_omniauth(access_token)
    puts access_token
    data = access_token.info
    user = User.where(:email => data["email"]).first

    GhostUserCreator.process_new_token(access_token, data)
    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
           email: data["email"],
           password: Devise.friendly_token[0,20]
        )
    end
    user
  end

end
