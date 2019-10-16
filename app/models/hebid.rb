class Hebid < ApplicationRecord
  include Status

  has_many :hebid_copyholders
  has_many :copyholders, through: :hebid_copyholders

  has_many :hebid_series
  has_many :series, through: :hebid_series

  has_many :hebid_subjects
  has_many :subjects, through: :hebid_subjects

  before_save { self.hebid = hebid.downcase }
  validates :hebid,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 17, maximum: 17 }
  validates :status,
            presence: false
end
