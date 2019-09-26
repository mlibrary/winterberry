class Review < ApplicationRecord
  validates :journal_abbrev,
            presence: true
  validates :review_label,
            presence: true
  validates :review_url,
            presence: true
end
