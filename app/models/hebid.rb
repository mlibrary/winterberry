class Hebid < ActiveRecord::Base
  before_save { self.hebid = hebid.downcase }
  validates :hebid,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 17, maximum: 17 }
end
