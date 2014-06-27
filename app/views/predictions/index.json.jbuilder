json.array!(@predictions) do |prediction|
  json.extract! prediction, :id, :game_id, :country1_id, :country2_id, :country1_goals, :country2_goals
  json.url prediction_url(prediction, format: :json)
end
