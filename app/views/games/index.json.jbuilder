json.array!(@games) do |game|
  json.extract! game, :id, :number, :type, :datetime, :country1_id, :country1_goals, :country2_id, :country2_goals
  json.url game_url(game, format: :json)
end
