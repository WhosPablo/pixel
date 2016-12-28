class SlackQuestionIndex < ApplicationRecord
  # Associations
  belongs_to :question, dependent: :destroy

end
