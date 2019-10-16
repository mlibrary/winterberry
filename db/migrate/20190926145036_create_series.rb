class CreateSeries < ActiveRecord::Migration[5.2]
  def change
    create_table :series do |t|
      t.string :series_title
      t.integer :status
      t.timestamps
    end
  end
end
