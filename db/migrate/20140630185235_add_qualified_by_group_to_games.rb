class AddQualifiedByGroupToGames < ActiveRecord::Migration
  def change
    add_column :games, :first_place_group_id, :integer
    add_column :games, :second_place_group_id, :integer
  end
end
