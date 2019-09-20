class Copyholder < ActiveRecord::Base
  belongs_to :hebid
  validates :copyholder,
            presence: true
  validates :url,
            presence: false
  validates :hebid_id,
            presence: true
end
