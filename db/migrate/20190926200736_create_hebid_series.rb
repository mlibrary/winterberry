class CreateHebidSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :hebid_series do |t|
      t.integer :hebid_id
      t.integer :series_id
    end
  end
end
