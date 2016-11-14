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

  def recipients_list=(recipient_csv)
    user_recipients = convert_recipients_csv_to_user_objs(recipient_csv)
    self.recipients << user_recipients
  end

  #TODO maybe move this from here
  def convert_recipients_csv_to_user_objs(recipients)
    recipients = recipients.split(/,\s+/)

    recipients.map do | recipient_username_or_email |

      recipient_by_username = User.find_by_username(recipient_username_or_email.downcase)
      recipient_by_email = User.find_by_email(recipient_username_or_email.downcase)

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
  end

end
