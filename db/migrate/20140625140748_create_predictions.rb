class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :country1_id
      t.integer :country2_id
      t.integer :country1_goals
      t.integer :country2_goals
      t.integer :points
      t.boolean :done, default: false
      t.timestamps
    end
  end
end