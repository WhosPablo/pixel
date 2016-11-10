class Question < ApplicationRecord
  belongs_to :user

  has_many :question_recipients
  has_many :recipients, through: :question_recipients, source: :user
end
