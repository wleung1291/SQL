class House < ApplicationRecord
  has_many :gardeners,
    class_name: 'Gardener',
    foreign_key: :house_id,
    primary_key: :id

  has_many :plants,
    through: :gardeners,
    source: :plants

  def n_plus_one_seeds
    plants = self.plants
    seeds = []
    plants.each do |plant|
      seeds << plant.seeds
    end

    seeds
  end

  # Create an array of all the seeds within a given house.
  def better_seeds_query
    # TODO: your code here
    plants = self.plants.includes(:seeds)
      #.select("*")
      #.joins(:seeds)

    seeds = []
    # will not fire a query for each route since drivers have already 
    # been prefetched
    plants.each do |plant|
      seeds << plant.seeds
    end

    seeds
  end
end
