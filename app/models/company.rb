class Company < ActiveRecord::Base
  has_many :users, class_name: 'User', foreign_key: :companies_id
  has_many :slack_teams, foreign_key: :companies_id
  has_many :slack_channels, foreign_key: :companies_id
end
