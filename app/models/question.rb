class Question < ApplicationRecord
  belongs_to :user

  has_many :question_recipients
  has_many :recipients, through: :question_recipients, source: :user

  acts_as_commentable

  def belongs_to(user_to_check)
    user_id == user_to_check.id
  end
end
