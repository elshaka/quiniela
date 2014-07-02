class Game < ActiveRecord::Base
  belongs_to :group
  belongs_to :country1, class_name: 'Country'
  belongs_to :country2, class_name: 'Country'
  belongs_to :previous_match1, class_name: 'Game'
  belongs_to :previous_match2, class_name: 'Game'
  belongs_to :first_place_group, class_name: 'Group'
  belongs_to :second_place_group, class_name: 'Group'
  has_many :predictions

  validates :date, presence: true
  validates :country1_goals, :country2_goals, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validate :goals_presence
  validate :winner

  before_save :set_played, :set_defined
  after_save :update_countries_stats, if: :played

  def goals_presence
    if country1_goals.blank? and country2_goals.present?
      errors.add(:country1_goals, 'Resultado incompleto')
    elsif country2_goals.blank? and country1_goals.present?
      errors.add(:country2_goals, 'Resultado incompleto')
    end
  end

  def winner
    if type != FASEDEGRUPOS
      country1_goals != country2_goals
    else
      true
    end
  end

  def set_played
    self.played = country1_goals.present? and country2_goals.present?
    if self.played
      self.predictions.where(done: true).each { |p| p.update_points }
    else
      Prediction.where(game_id: self.id).update_all(points: nil)
    end
    true
  end

  def set_defined
    self.defined = true if type == FASEDEGRUPOS
    true
  end

  def get_winner
    if country1_goals > country2_goals
      country1
    elsif country1_goals < country2_goals
      country2
    else
      nil
    end
  end

  def update_countries_stats
    if type == FASEDEGRUPOS
      # country1
      pg = pe = pp = gf = gc = dif = 0
      # country1 como country1
      games = Game
        .where(country1_id: self.country1_id)
        .where(played: true)
        .where(type: FASEDEGRUPOS)
      games.each do |game|
        pg += 1 if game.country1_goals > game.country2_goals
        pe += 1 if game.country1_goals == game.country2_goals
        pp += 1 if game.country1_goals < game.country2_goals
        gf += game.country1_goals
        gc += game.country2_goals
      end
      # country1 como country2
      games = Game
        .where(country2_id: self.country1_id)
        .where(played: true)
      games.each do |game|
        pg += 1 if game.country2_goals > game.country1_goals
        pe += 1 if game.country2_goals == game.country1_goals
        pp += 1 if game.country2_goals < game.country1_goals
        gf += game.country2_goals
        gc += game.country1_goals
      end
      self.country1.points = 3 * pg + 1 * pe
      self.country1.pj = pg + pe + pp
      self.country1.pg = pg
      self.country1.pe = pe
      self.country1.pp = pp
      self.country1.gf = gf
      self.country1.gc = gc
      self.country1.dif = gf - gc
      self.country1.save

      # country2
      pg = pe = pp = gf = gc = dif = 0
      # country2 como country1
      games = Game
        .where(country1_id: self.country2_id)
        .where(played: true)
      games.each do |game|
        pg += 1 if game.country1_goals > game.country2_goals
        pe += 1 if game.country1_goals == game.country2_goals
        pp += 1 if game.country1_goals < game.country2_goals
        gf += game.country1_goals
        gc += game.country2_goals
      end
      # country2 como country2
      games = Game
        .where(country2_id: self.country2_id)
        .where(played: true)
      games.each do |game|
        pg += 1 if game.country2_goals > game.country1_goals
        pe += 1 if game.country2_goals == game.country1_goals
        pp += 1 if game.country2_goals < game.country1_goals
        gf += game.country2_goals
        gc += game.country1_goals
      end
      self.country2.points = 3 * pg + 1 * pe
      self.country2.pj = pg + pe + pp
      self.country2.pg = pg
      self.country2.pe = pe
      self.country2.pp = pp
      self.country2.gf = gf
      self.country2.gc = gc
      self.country2.dif = gf - gc
      self.country2.save
    end
  end

  FASEDEGRUPOS = 1
  OCTAVOS = 2
  CUARTOS = 3
  SEMIFINALES = 4
  TERCERO = 5
  FINAL = 6

  TYPE_STRINGS = {
    1 => 'Fase de grupos',
    2 => 'Octavos',
    3 => 'Cuartos',
    4 => 'Semifinales',
    5 => 'Tercero',
    6 => 'Final'
  }

  self.inheritance_column = nil
end