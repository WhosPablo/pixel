class User < ActiveRecord::Base

  include PublicActivity::Model
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  before_save :downcase_fields
  before_create :assign_company, :set_username_on_create

  validate do |user|
    user.must_have_corp_email unless user.is_quiki_member
  end

  belongs_to :company, class_name: 'Company', foreign_key: :companies_id
  has_many :comments
  has_many :questions_asked, class_name: 'Question', foreign_key: :user_id
  has_many :question_recipients
  has_many :questions_received, through: :question_recipients, source: :question

  acts_as_follower
  acts_as_followable

  #TODO allow for more fields to be passed and have create_ghost_users call this?
  def self.create_ghost_user_from_email(user_info)
    if user_info[:email]
      User.find_or_create_by(email: user_info[:email].downcase) do | new_user_obj |
        new_user_obj.is_ghost_user = true
        new_user_obj.password = Devise.friendly_token[0,20]
        new_user_obj.confirmed_at = DateTime.now
        new_user_obj.save!
      end
    end
    #TODO what if no email is passed?
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(
            first_name: data["first_name"],
            last_name: data["last_name"],
            email: data["email"],
            password: Devise.friendly_token[0,20],
            confirmed_at: DateTime.now
        )
        user.skip_confirmation!
    end

    if user.errors.empty?
      ImportDirectoryContactsJob.perform_later access_token, user
    end
    user

  end

  def initials
    self.full_name.split(' ').collect { |s| s[0].upcase }.join('')
  end

  def is_quiki_member
    ["lucianoarango@gmail.com", "lucianoa007@gmail.com", "nabeysen@gmail.com"]
        .include?(self.email)
  end

  def is_admin
    ["quiki@getrileynow.com", "lucianoarango@gmail.com", "luciano@askquiki.com", "nabeysen@gmail.com", "natalie@askquiki.com"]
        .include?(self.email)
  end

  def full_name
    if self.first_name and self.last_name
      [self.first_name, self.last_name].join(' ')
    else # fallback on username which is always present
      self.username
    end
  end

  def full_name=(full_name)
    name_array = full_name.split(' ')
    self.first_name = name_array.first
    self.last_name  = name_array.drop(1).join(' ')
  end

  def get_new_notifications
    self.activities.where('created_at > ?', self.last_notification_ack).order(created_at: :desc)
  end

  def must_have_corp_email
    domain = self.email.split("@").second
    #TODO checks for more personal accounts
    errors.add(:base, 'Email must have a corporate domain') unless domain != "gmail.com" and domain != "hotmail.com" and
        domain != "outlook.com"
  end

  def turn_ghost_user_to_real_user(params)
    if self.is_ghost_user
      self.update(ghost_user_to_user_params(params))
      self.is_ghost_user = false
      self.confirmed_at = nil
      self.send_confirmation_instructions
      set_username_on_create
      self.save!
      self
    end
  end

  private

  def ghost_user_to_user_params(params)
    params.require(:user).permit(:full_name, :is_ghost_user, :password, :password_confirmation)
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

  def assign_company
    if self.company.blank?
      self.company = Company.find_or_create_by(domain: self.email.split("@").second)
    end
  end

  #TODO messy, clean this up
  def set_username_on_create
    company = self.company
    if self.first_name and self.last_name
      users_with_same_name = User.where(first_name: self.first_name.downcase, last_name: self.last_name.downcase, companies_id:
          company.id)
      last_name_no_spaces = self.last_name.split(' ').join
      if users_with_same_name.count == 0 or (users_with_same_name.count == 1 and users_with_same_name.first == self)
        self.username = "#{self.first_name.downcase}.#{last_name_no_spaces.downcase}"
      else
        self.username = "#{self.first_name.downcase}.#{last_name_no_spaces.downcase}.#{users_with_same_name.count.to_s.rjust(2, '0')}"
      end
    else
      possible_username = self.email.split("@").first.downcase
      users_with_same_username = User.where(username: possible_username, companies_id: company.id)
      if users_with_same_username.count == 0 or (users_with_same_username.count == 1 and users_with_same_username.first == self)
        self.username = "#{possible_username}"
      else
        self.username = "#{possible_username}.#{users_with_same_username.count.to_s.rjust(2, '0')}"
      end
    end
  end

end
