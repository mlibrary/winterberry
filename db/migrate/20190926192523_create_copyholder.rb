class CreateCopyholder < ActiveRecord::Migration[5.2]
  def change
    create_table :copyholders do |t|
      t.string :copyholder
      t.string :url

      t.timestamps
    end
  end
end
