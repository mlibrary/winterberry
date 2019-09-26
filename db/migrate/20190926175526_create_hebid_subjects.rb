class CreateHebidSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :hebid_subjects do |t|
      t.integer :hebid_id
      t.integer :subject_id
    end
  end
end
