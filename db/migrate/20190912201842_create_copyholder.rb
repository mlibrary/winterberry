class CreateCopyholder < ActiveRecord::Migration[5.2]
  def change
    create_table :copyholders do |t|
      t.integer :hebid_id
      t.string :copyholder
      t.string :url
      t.timestamps
    end
  end
end
