class CreateHebidCopyholders < ActiveRecord::Migration[5.2]
  def change
    create_table :hebid_copyholders do |t|
      t.integer :hebid_id
      t.integer :copyholder_id
    end
  end
end
