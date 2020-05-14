class Ingredient < ApplicationRecord
  has_many :doses
  # belongs_to :cockatail
  validates :name, uniqueness: true
end
