class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }
end

# Same name, different body — NOT a duplicate expression
class Stance < ApplicationRecord
  scope :guests, -> { where(guest: true) }
  scope :guests, -> { where("inviter_id is not null") }
end

# Scopes with block extensions are different even if lambda body matches
class Topic < ApplicationRecord
  scope :with_lambda, lambda { all }
  scope :with_extension, -> { all } do
    def one; 1; end
  end
end
