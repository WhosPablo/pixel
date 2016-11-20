class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]
  before_save :downcase_fields
  before_create :assign_company, :set_username_on_create

  validate do |user|
    user.must_have_corp_email
  end

  belongs_to :company, class_name: 'Company', foreign_key: :companies_id
  has_many :comments
  has_many :questions_asked, class_name: 'Question', foreign_key: :user_id
  has_many :question_recipients
  has_many :questions_received, through: :question_recipients, source: :question

  acts_as_follower
  acts_as_followable

  #TODO allow for more fields to be passed and have create ghost users call this?
  def self.create_ghost_user(user_info)
    if user_info[:email]
      User.find_or_create_by(email: user_info[:email].downcase) do |new_user_obj|
        new_user_obj.is_ghost_user = true
        new_user_obj.password = Devise.friendly_token[0,20]
        new_user_obj.save!
      end
    end
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
            password: Devise.friendly_token[0,20]
        )
    end
    if not user.errors.empty?
      user
    else
      ImportDirectoryContactsJob.perform_later access_token, user
      user
    end
  end

  def must_have_corp_email
    domain = self.email.split("@").second
    #TODO add more checks
    errors.add(:base, 'Must sign in with corporate email') unless domain != "gmail.com" and domain != "hotmail.com"
  end

  def full_name
    if self.first_name and self.last_name
      [self.first_name, self.last_name].join(' ')
    end
  end

  def full_name=(full_name)
    self.first_name = full_name.split(' ').first
    self.last_name  = full_name.split(' ').second
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

  def assign_company
    self.company = Company.find_or_create_by(domain: self.email.split("@").second)
  end

  def set_username_on_create
    if self.first_name and self.last_name
      company = Company.find_by_domain(self.email.split("@").second)
      same_name_users = User.where(first_name: self.first_name.downcase, last_name: self.last_name.downcase, companies_id:
          company.id)
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
