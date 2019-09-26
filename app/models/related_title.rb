class RelatedTitle < ApplicationRecord
  validates :related_hebid,
            presence: false
  validates :related_title,
            presence: true
  validates :related_authors,
            presence: false
  validates :related_pubinfo,
            presence: true
end
