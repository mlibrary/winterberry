class Series < ApplicationRecord
  include Status

  has_many :hebid_series
  has_many :hebid, through: :hebid_series

  validates :series_title,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :status,
            presence: false
end
