class Subject < ApplicationRecord
  include Status

  has_many :hebid_subjects
  has_many :hebid, through: :hebid_subjects

  validates :subject_title,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :status,
            presence: false
end
