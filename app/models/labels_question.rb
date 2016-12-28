class LabelsQuestion < ApplicationRecord
  belongs_to :label, counter_cache: :questions_count
  belongs_to :question
end
