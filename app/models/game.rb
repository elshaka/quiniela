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
  validate :has_winner

  before_save :set_played, :set_defined
  after_save :update_countries_stats, if: :played
  after_save :update_qualified

  def goals_presence
    if country1_goals.blank? and country2_goals.present?
      errors.add(:country1_goals, 'Resultado incompleto')
    elsif country2_goals.blank? and country1_goals.present?
      errors.add(:country2_goals, 'Resultado incompleto')
    end
  end

  def has_winner
    if type != FASEDEGRUPOS
      if country1_goals != nil and country2_goals != nil
        if country1_goals == country2_goals
          errors.add(:country1_goals, "No puede terminar en empate")
        end
      end
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
    if type == FASEDEGRUPOS
      self.defined = true
    elsif country1_id.present? and country2_id.present?
      self.defined = true
    else
      self.defined = false
    end
    true
  end

  def get_winner_and_loser
    if country1_goals > country2_goals
      {winner: country1, loser: country2}
    elsif country1_goals < country2_goals
      {winner: country2, loser: country1}
    else
      nil
    end
  end

  def clear
    self.update_column(:defined, false)
    self.update_column(:played, false)
    self.update_column(:country1_id, nil)
    self.update_column(:country2_id, nil)
    self.update_column(:country1_goals, nil)
    self.update_column(:country2_goals, nil)
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

  def update_qualified
    if type == FASEDEGRUPOS
      # Limpiar campos de fase de cuartos en adelante
      transaction do
        Game.where(type: CUARTOS .. SEMIFINALES).each { |g| g.clear }
      end
      transaction do
        Game.where(type: OCTAVOS .. SEMIFINALES).each do |g|
          g.update_column(:country1_goals, nil)
          g.update_column(:country2_goals, nil)
          g.update_column(:played, false)
        end
      end

      # Octavos de final al que iran primero y segundo de grupo
      octavo1 = Game
        .where(type: Game::OCTAVOS, first_place_group_id: self.group_id)
        .first
      octavo2 = Game
        .where(type: Game::OCTAVOS, second_place_group_id: self.group_id)
        .first

      octavo1.country1_id = nil
      octavo2.country2_id = nil

      # Si se han jugado todos los juegos del grupo
      if Game.where(group_id: self.group_id, played: false).count == 0
        first_country, second_country = Country
          .where(group_id: self.group_id)
          .order('points DESC, dif DESC, gf DESC')
          .limit(2)
        octavo1.country1_id = first_country.id
        octavo2.country2_id = second_country.id
      # Si no, se limpian los campos de los octavos correspondientes
      end

      octavo1.country1_goals = nil
      octavo1.country2_goals = nil
      octavo1.save
      octavo1.country1_goals = nil
      octavo2.country2_goals = nil
      octavo2.save

    elsif type.between?(OCTAVOS, SEMIFINALES)
      # Se limpian los campos de los juegos de la fase siguiente a la siguiente (:D) en adelante
      transaction do
        Game.where(type: type + 2 .. SEMIFINALES).each { |g| g.clear }
      end
      transaction do
        Game.where(type: type + 1 .. SEMIFINALES).each { |g| g.save }
      end

      # Busca siguiente partido
      next_match = Game.where(type: type + 1, :previous_match1_id => self.id).first
      country_key = :country1_id
      if next_match.nil?
        next_match = Game.where(type: type + 1, :previous_match2_id => self.id).first
        country_key = :country2_id
      end

      next_match[country_key] = self.played ? self.get_winner_and_loser()[type != SEMIFINALES ? :winner : :loser].id : nil
      next_match.country1_goals = nil
      next_match.country2_goals = nil
      next_match.save

      # Busca la final
      if type == SEMIFINALES
        final = Game.where(type: FINAL, :previous_match1_id => self.id).first
        country_key = :country1_id
        if final.nil?
          final = Game.where(type: FINAL, :previous_match2_id => self.id).first
          country_key = :country2_id
        end
        final[country_key] = self.played ? self.get_winner_and_loser()[:winner].id : nil
        final.country1_goals = nil
        final.country2_goals = nil
        final.save
      end
    end
  end

  def self.generate_graph
    data = {nodes: {}, edges: {}}
    games = Game.where(type: (OCTAVOS .. FINAL))

    games.each do |game|
      game_key = "g#{game.id}".to_sym
      data[:nodes][game_key] = {
        'color' => TYPE_COLORS[game.type],
        'shape' => 'box',
        'label' => game.generate_node_text(),
        'size' => 100
      }
      
      unless game.previous_match1_id.nil?
        next_game1_key = "g#{game.previous_match1_id}".to_sym
        next_game2_key = "g#{game.previous_match2_id}".to_sym
        data[:edges][game_key] = {next_game1_key => {}, next_game2_key => {}}
      end
    end
    data
  end

  def generate_node_text
    country1_text = self.country1.present? ? self.country1.name[0..2].upcase : "#{self.type == TERCERO ? "P" : "G"}#{self.previous_match1.number}"
    country2_text = self.country2.present? ? self.country2.name[0..2].upcase : "#{self.type == TERCERO ? "P" : "G"}#{self.previous_match2.number}"
    "[#{self.number}] #{country1_text} #{self.country1_goals} : #{self.country2_goals} #{country2_text}"
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

  TYPE_COLORS = {
    1 => '#4D4D4D',
    2 => '#FF4500',
    3 => '#8A2BE2',
    4 => '#00FF00',
    5 => '#00BFFF',
    6 => '#0000FF'
  }

  self.inheritance_column = nil
end