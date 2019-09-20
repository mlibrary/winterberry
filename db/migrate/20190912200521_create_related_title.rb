class CreateRelatedTitle < ActiveRecord::Migration[5.2]
  def change
    create_table :related_titles do |t|
      t.integer :hebid_id
      t.string :related_hebid
      t.string :related_title
      t.string :related_authors
      t.string :related_pubinfo
      t.timestamps
    end
  end
end
