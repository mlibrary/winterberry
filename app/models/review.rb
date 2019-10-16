class Review < ApplicationRecord
  include Status

  validates :journal_abbrev,
            presence: true
  validates :review_label,
            presence: true
  validates :review_url,
            presence: true
  validates :status,
            presence: false
end
