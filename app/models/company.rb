class Company < ActiveRecord::Base
  has_many :users, class_name: 'User', foreign_key: :companies_id


end
