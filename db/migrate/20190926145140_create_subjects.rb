class CreateSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects do |t|
      t.string :subject_title
      t.integer :status
      t.timestamps
    end
  end
end
