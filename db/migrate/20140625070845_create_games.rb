class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :number
      t.integer :type
      t.date :date
      t.integer :country1_id
      t.integer :country1_goals
      t.integer :country2_id
      t.integer :country2_goals
      t.boolean :defined, default: false
      t.boolean :played, default: false
      t.references :group
      t.timestamps
    end
  end
end
