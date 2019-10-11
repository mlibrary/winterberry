class CreateHebidReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :hebid_reviews do |t|
      t.integer :hebid_id
      t.string :journal_abbrev
      t.string :review_label
      t.string :review_url
      t.timestamps
    end
  end
end
