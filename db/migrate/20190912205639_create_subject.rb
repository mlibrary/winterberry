class CreateSubject < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects do |t|
      t.integer :hebid_id
      t.string :title
      t.timestamps
    end
  end
end
