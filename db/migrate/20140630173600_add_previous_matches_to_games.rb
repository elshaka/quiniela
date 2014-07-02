class AddPreviousMatchesToGames < ActiveRecord::Migration
  def change
    add_column :games, :previous_match1_id, :integer
    add_column :games, :previous_match2_id, :integer
  end
end
