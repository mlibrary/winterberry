class Series < ActiveRecord::Base
  belongs_to :hebid
  validates :title,
            presence: true
  validates :hebid_id,
            presence: true
end
