class HebidReview < ApplicationRecord
  belongs_to :hebid

  validates :hebid_id,
            presence: true
  validates :journal_abbrev,
            presence: false
  validates :review_label,
            presence: false
  validates :review_url,
            presence: false
end
