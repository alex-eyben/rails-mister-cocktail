# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# require 'open-uri'

# puts "Destroy ingredients"
# Ingredient.destroy_all if Rails.env.development?

# puts "Destroy Cocktails"
# Cocktail.destroy_all if Rails.env.development?

# puts "Create ingredients"
# url = "https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
# ingredients = JSON.parse(open(url).read)
# ingredients["drinks"].each do |ingredient|
#   i = Ingredient.create(name: ingredient["strIngredient1"])
#   puts "create #{i.name}"
# end

require 'open-uri'
require 'json'

Ingredient.destroy_all
Cocktail.destroy_all
Dose.destroy_all

def ingredients_creation
  url = 'https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list'
  JSON.parse(URI.parse(url).open.read)['drinks'].each do |ingredient|
    newingredient = Ingredient.new(name: ingredient['strIngredient1'])
    newingredient.save!
    puts "Creating Ingredient #{newingredient.name}"
  end
end

def cocktails_creation
  ('a'..'z').to_a.each do |letter|
    url = "https://www.thecocktaildb.com/api/json/v1/1/search.php?f=#{letter}"
    next if JSON.parse(URI.parse(url).open.read)['drinks'].nil?

    make_doses_and_cocktails(url)
  end
end

def make_doses_and_cocktails(url)
  JSON.parse(URI.parse(url).open.read)['drinks'].each do |c|
    doses_creation(c, create_cocktail(c))
  end
end

def create_cocktail(cocktail)
  new_cocktail = Cocktail.new(
    name: cocktail['strDrink']
  )
  new_cocktail.photo.attach(
    io: URI.parse(cocktail['strDrinkThumb']).open,
    filename: cocktail['strDrinkThumb'][-15..-1]
  )
  new_cocktail.save if new_cocktail.valid?
  puts "Creating #{new_cocktail.name}"
end

def doses_creation(cocktail, new_cocktail)
  (1..5).to_a.each do |number|
    next if cocktail["strMeasure#{number}"].nil? || Ingredient.find_by(
      name: cocktail["strIngredient#{number}"]
    ).nil?

    dose = Dose.new(description: cocktail["strMeasure#{number}"])
    ingredient = Ingredient.find_by(name: cocktail["strIngredient#{number}"])
    dose.cocktail = new_cocktail
    dose.ingredient = ingredient
    dose.save! if dose.valid?
    puts "Creating #{dose.description}"
  end
end

def seed_all
  ingredients_creation
  cocktails_creation
end

seed_all
