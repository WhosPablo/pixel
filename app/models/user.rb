class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  before_save :downcase_fields
  before_create :set_username_on_create

  has_many :questions_asked, class_name: 'Question', foreign_key: :user_id

  has_many :question_recipients
  has_many :questions_received, through: :question_recipients, source: :question

  acts_as_follower
  acts_as_followable

  def self.from_omniauth(access_token)
    puts access_token
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
            first_name: data["first_name"],
            last_name: data["last_name"],
            email: data["email"],
            password: Devise.friendly_token[0,20]
        )
    end

    GhostUserCreator.start_with_google_token(access_token, user)
    user
  end


  def turn_ghost_user_to_real_user(params)
    if self.is_ghost_user
      self.update(ghost_user_to_user_params(params))
      self.is_ghost_user = false
      self.save!
      self
    end
  end

  private

  def ghost_user_to_user_params(params)
    params.require(:user).permit(:first_name, :last_name, :is_ghost_user, :password, :password_confirmation)
  end

  def downcase_fields
    if self.first_name
      self.first_name.downcase!
    end
    if self.last_name
      self.last_name.downcase!
    end
    self.email.downcase!
  end

  def set_username_on_create
    if self.first_name and self.last_name
      same_name_users = User.where(first_name: self.first_name.downcase, last_name: self.last_name.downcase)
      if same_name_users and same_name_users.count > 0
        self.username = "#{self.first_name.downcase}.#{self.last_name.downcase}.#{same_name_users.count.to_s.rjust(2, '0')}"
      else
        self.username = "#{self.first_name.downcase}.#{self.last_name.downcase}"
      end
    else
      self.username = self.email.downcase
    end
  end

end
