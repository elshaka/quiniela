class Prediction < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  validates :country1_goals, :country2_goals, numericality: {greater_than_or_equal_to: 0, allow_nil: true}
  validate :goals_presence

  before_save :set_done
  after_save :update_points, if: :done

  def goals_presence
    if country1_goals.blank? and country2_goals.present?
      errors.add(:country1_goals, 'Resultado incompleto')
    elsif country2_goals.blank? and country1_goals.present?
      errors.add(:country2_goals, 'Resultado incompleto')
    end
  end

  def set_done
    self.done = country1_goals.present? and country2_goals.present?
    self.points = nil unless self.done
    true
  end

  def update_points
    if self.done and self.game.played
      points = 0
      # Acierta marcador
      if self.country1_goals == self.game.country1_goals and self.country2_goals == self.game.country2_goals
        points = 3
      else
        p_diff = self.country1_goals - self.country2_goals
        g_diff = self.game.country1_goals - self.game.country2_goals
        # Acierta ganador o empate
        if ((p_diff == 0 and g_diff == 0) or (p_diff < 0 and g_diff < 0) or (p_diff > 0 and g_diff > 0))
          points = 1
        end
      end
      self.update_column(:points, points)
    end
  end
end