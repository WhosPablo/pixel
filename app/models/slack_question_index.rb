class SlackQuestionIndex < ApplicationRecord
  # Associations
  belongs_to :question, dependent: :destroy
  belongs_to :user, foreign_key: :users_id
end
