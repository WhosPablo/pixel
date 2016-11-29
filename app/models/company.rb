class Company < ActiveRecord::Base
  has_many :users, class_name: 'User'

end
