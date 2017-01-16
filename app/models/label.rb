class Label < ApplicationRecord

  belongs_to :company, class_name: 'Company', foreign_key: :companies_id
  has_many :labels_questions, dependent: :destroy
  has_many :questions, :through => :labels_questions

end
