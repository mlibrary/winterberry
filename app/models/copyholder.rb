class Copyholder < ApplicationRecord
  include Status

  has_many :hebid_copyholders
  has_many :hebid, through: :hebid_copyholders

  validates :copyholder,
            presence: true,
            uniqueness: { case_sensitive: false }
  validates :url,
            presence: false
  validates :status,
            presence: false
end
