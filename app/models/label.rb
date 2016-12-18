class Label < ApplicationRecord

  belongs_to :company, class_name: 'Company', foreign_key: :companies_id
  has_and_belongs_to_many :questions

end
