class Post < ActiveRecord::Base
  has_many :images, dependent: :destroy

  scope :by_newest, -> { order("created_at DESC") }
end
