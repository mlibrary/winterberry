class CreateHebid < ActiveRecord::Migration[5.2]
  def change
    create_table :hebids do |t|
      t.string :hebid
      t.integer :status
      t.timestamps
    end
  end
end
