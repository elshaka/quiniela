class AddStatToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :points, :integer, :default => 0
    add_column :countries, :pj, :integer, :default => 0
    add_column :countries, :pg, :integer, :default => 0
    add_column :countries, :pe, :integer, :default => 0
    add_column :countries, :pp, :integer, :default => 0
    add_column :countries, :gf, :integer, :default => 0
    add_column :countries, :gc, :integer, :default => 0
    add_column :countries, :dif, :integer, :default => 0
  end
end