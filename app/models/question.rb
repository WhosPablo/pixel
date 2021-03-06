require 'elasticsearch/model'

class Question < ApplicationRecord

  # Libraries
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include PublicActivity::Model

  # Associations
  belongs_to :company, class_name: 'Company', foreign_key: :companies_id
  has_many :question_recipients
  has_many :recipients, through: :question_recipients, source: :user,  dependent: :destroy
  has_many :labels_questions, dependent: :destroy
  has_many :labels, :through => :labels_questions
  has_one :slack_question_index, dependent: :destroy
  belongs_to :user


  # Settings
  acts_as_commentable
  default_scope -> { order('created_at DESC') }

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :body, analyzer: 'english'
      indexes :companies_id, type: 'long'
    end
  end

  tracked only: [:create], owner: proc { |_controller, model| model.user } #, recipient: proc { |_controller, model| model.recipients }

  # Validations
  after_commit :create_all_activity, on: [:create, :update]
  before_validation :assign_company
  before_validation :convert_recipients
  before_validation :convert_labels


  validate do |question|
    question.recipients_are_inside_company
  end

  validates_presence_of :user
  validates_presence_of :body

  # Additional attributes
  attr_accessor :recipients_csv
  attr_accessor :labels_list

  def auto_populate_labels
    labels = LabelCreator.generate_labels(self.body)
    self.labels_list = labels.present? ? labels.keys : []
  end

  def auto_populate_labels!
   self.auto_populate_labels
   self.convert_labels
  end


  def belongs_to(user_to_check)
    user_id == user_to_check.id
  end

  def convert_labels
    self.labels.destroy_all
    unless self.labels_list.blank?
      self.labels << self.labels_list.map do | label |
        Label.find_or_create_by(name: label.downcase, company: self.company)
      end
    end
  end

  def convert_recipients
    self.recipients.destroy_all
    self.recipients << recipients_csv_to_user_obj(self.recipients_csv, self.user)
  end

  def is_recipient(user_to_check)
    self.question_recipients.exists?(user_id: user_to_check.id)
  end

  def labels_csv
    self.labels.map { |t| t.name }.join(' ,')
  end

  def labels_csv=(labels_csv)
    self.labels_list = labels_csv.split(',').map(&:strip)
  end

  def recipients_are_inside_company
    self.question_recipients.each do | recipient |
      if self.company != recipient.user.company
        errors.add(:base, "You can only ask people from your company and #{recipient.user.username} is not in your company")
      end
    end
  end

  def recipients_list_csv
    self.recipients.map { |t| t.username }.join(' ,')
  end

  def recipients_list_csv=(recipient_csv)
    self.recipients_csv = recipient_csv
  end




  def recipients_csv_to_user_obj(recipients_csv, user)
    unless recipients_csv.blank?
      recipients = recipients_csv.split(',').map(&:strip)
      recipients.map do | recipient_username_or_email |
        unless recipient_username_or_email.blank?
          recipient = find_recipient_by_username_or_email(recipient_username_or_email.downcase, user.companies_id)
          #TODO fix race condition here between checking if user exists and creating one
          if recipient.blank?
            create_ghost_user_from_recipient(recipient_username_or_email, user)
          else
            recipient
          end
        end
      end .compact
    else
      []
    end
  end

  def self.search(query, viewer)
    __elasticsearch__.search(
        {
            query: {
                bool: {
                    must: {
                      multi_match: {
                        query:  query,
                        # fuzziness: "AUTO",
                        fields: ['body']
                      }
                    },
                    filter: {
                        term: {
                            companies_id: viewer.company.id
                        }
                    }
                }
            },
            highlight: {
                pre_tags: ['<em>'],
                post_tags: ['</em>'],
                fields: {
                    body: {}
                }
            }
        }
    )
  end


  def self.find_relevant_question(query, company)
    __elasticsearch__.search(
        {
            query: {
                bool: {
                    must: {
                        multi_match: {
                            query:  query,
                            cutoff_frequency: 0.008,
                            # fuzziness: "AUTO",
                            fields: ['body']
                        }

                    },
                    filter: {
                        term: {
                            companies_id: company.id
                        }
                    }

                }
            }

        }
    )
  end

  private

  def assign_company
    if self.company.blank?
      self.company = self.user.company
    end
  end

  def create_all_activity
    QuestionActivityJob.perform_later(self)
  end

  def create_ghost_user_from_recipient(recipient_username_or_email, default_user)
    #TODO add email checks instead before trying to create a user?
    begin
      User.create_ghost_user_from_email(email: recipient_username_or_email.downcase)
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message + " for ''" + recipient_username_or_email + "''")
      default_user #return yourself as default (should fail validation anyways due to errors )
    end
  end

  def find_recipient_by_username_or_email(username_or_email, company_id)
    User.where('(username = ? AND companies_id = ?) OR email = ?', username_or_email, company_id, username_or_email).first
  end

end

