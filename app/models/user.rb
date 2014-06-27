class User < ActiveRecord::Base
  has_many :predictions, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  after_create :create_predictions

  def create_predictions
    transaction do
      Game.all.each do |game|
        prediction = Prediction.new
        prediction.user = self
        prediction.game = game
        prediction.save
      end
    end
  end

  def get_predictions
    Group.all.inject({}) do |hash, group|
      hash[group.id] = Prediction
        .includes(game: {country1: {}, country2: {}})
        .where(user_id: self.id)
        .where(games: {group_id: group.id})
        .order('games.date ASC')
      hash
    end
  end

  def get_points
    return self.predictions.sum(:points)
  end

  def self.get_all_points
    Prediction
      .joins(:user)
      .select('user_id, users.name AS name, SUM(points) AS points')
      .group('user_id')
      .order('points DESC')
      .inject({}) do |hash, pp|
        hash[pp[:user_id]] = {name: pp[:name], points: pp[:points]}
        hash
    end
  end
end