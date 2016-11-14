class Question < ApplicationRecord
  belongs_to :user

  has_many :question_recipients
  has_many :recipients, through: :question_recipients, source: :user

  acts_as_commentable

  def belongs_to(user_to_check)
    user_id == user_to_check.id
  end

  def recipients_list
    self.recipients.map { |t| t.username }.join(", ")
  end

  def recipients_list=(new_value)
    recipients = new_value.split(/,\s+/)
    puts recipients
    user_recipients = recipients.map do | recipient_username_or_email |

      recipient_by_username = User.where(username: recipient_username_or_email.downcase)
      recipient_by_email = User.where(email: recipient_username_or_email.downcase)

      #TODO fix race condition here between checking if user exists and creating one
      if recipient_by_username.blank? and recipient_by_email.blank?
        #TODO add email checks
        User.create_ghost_user(email: recipient_username_or_email.downcase)
      elsif recipient_by_email.blank? # Then we must have found him by username
        recipient_by_username
      else
        recipient_by_email
      end
    end
    self.recipients << user_recipients
  end

end
