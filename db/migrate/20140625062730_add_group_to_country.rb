class AddGroupToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :group_id, :integer, null: false, default: 1
  end
end
