require 'elasticsearch/model'

class Question < ApplicationRecord

  # Libraries
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include PublicActivity::Model

  # Associations
  belongs_to :user
  has_many :question_recipients
  has_many :recipients, through: :question_recipients, source: :user

  #Settings
  acts_as_commentable
  default_scope -> { order('created_at DESC') }
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :body, analyzer: 'english'
    end
  end

  tracked only: [:create], owner: proc { |_controller, model| model.user } #, recipient: proc { |_controller, model| model.recipients }

  #Validations
  after_create :create_all_activity
  before_validation :convert_recipients
  validate do |question|
    question.recipients_are_inside_company
  end

  # Additional attributes
  attr_accessor :headless
  attr_accessor :recipients_csv



  def belongs_to(user_to_check)
    user_id == user_to_check.id
  end

  def is_recipient(user_to_check)
    self.question_recipients.exists?(user_id: user_to_check.id)
  end

  def recipients_are_inside_company
    self.question_recipients.each do | recipient |
      if self.user.company != recipient.user.company
        errors.add(:base, "You can only ask people from your company and #{recipient.user.username} is not in your company")
      end
    end

  end

  def recipients_list_csv
    self.recipients.map { |t| t.username }.to_sentence
  end

  def recipients_list_csv=(recipient_csv)
    self.recipients_csv = recipient_csv
  end

  def convert_recipients
    unless self.recipients_csv.blank?
      self.recipients << recipients_csv_to_user_obj(self.recipients_csv, self.user)
    end

  end


  def recipients_csv_to_user_obj(recipients_csv, user)
    recipients = recipients_csv.split(/,\s+/)

    recipients.map do | recipient_username_or_email |

      recipient = find_recipient_by_username_or_email(recipient_username_or_email.downcase, user.companies_id)
      #TODO fix race condition here between checking if user exists and creating one
      if recipient.blank?
        create_ghost_user_from_recipient(recipient_username_or_email, user)
      else
        recipient
      end
    end .compact
  end

  private


  def create_all_activity
    ActivityCreator.notifications_for_questions(self)
  end

  def find_recipient_by_username_or_email(username_or_email, company_id)
    User.where('(username = ? AND companies_id = ?) OR email = ?', username_or_email, company_id, username_or_email).first
  end

  def create_ghost_user_from_recipient(recipient_username_or_email, default_user)
    #TODO add email checks instead before trying to create a user?
    begin
      User.create_ghost_user(email: recipient_username_or_email.downcase)
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message + " for ''" + recipient_username_or_email + "''")
      default_user #return yourself as default (should fail validation anyways due to errors )
    end
  end

end
