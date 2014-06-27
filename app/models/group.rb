class Group < ActiveRecord::Base
  has_many :countries
  has_many :games
end