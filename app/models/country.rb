class Country < ActiveRecord::Base
  belongs_to :group
  has_many :games

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :group, presence: true
end