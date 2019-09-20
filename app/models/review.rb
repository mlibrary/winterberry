class Review < ActiveRecord::Base
  belongs_to :hebid
  validates :journal_abbrev,
            presence: true
  validates :review_label,
            presence: true
  validates :review_url,
            presence: true
  validates :hebid_id,
            presence: true
end
