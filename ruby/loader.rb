#!/usr/bin/ruby

class PersonPage
  attr_reader :name, :gender, :occupations

  def initialize(json)
    @name = json['name']
    @gender = json['gender']
    @gender = @gender.intern if @gender
    @occupations = json['occupations'].map { |xx| [xx[1], xx[0].intern] }.to_h
  end

end

class PlacePage
  attr_reader :name

  def initialize(json)
    @name = json['name']
    @info = json['info'].map { |xx| [xx[1], xx[0].intern] }.to_h
  end

  def type
    key = keyword
    key and @info[key]
  end

  def keyword
    freq = @info.each_with_object(Hash.new(0)) do |(key, val), hash|
      hash[val] += 1
    end
    mode = freq.max_by { |k, v| v }
    mode and @info.detect { |k, v| v == mode[0] }[0]
  end

end

class WeaponPage
  attr_reader :name, :type, :keyword

  def initialize(json)
    @name = json['name']
    @info = json['info'].map { |xx| [xx[1], xx[0].intern] }.to_h
  end

  def type
    key = keyword
    key and @info[key]
  end

  def keyword
    freq = @info.each_with_object(Hash.new(0)) do |(key, val), hash|
      hash[val] += 1
    end
    mode = freq.max_by { |k, v| v }
    mode and @info.detect { |k, v| v == mode[0] }[0]
  end

end

class AnimalPage
  attr_reader :name, :pack, :speed, :sea, :air, :threat, :size

  def initialize(json)
    @name = json['name']
    @pack = json['pack']
    @speed = json['speed']
    @sea = json['sea']
    @air = json['air']
    @threat = json['threat']
    @size = json['size']
    @matches = json['matches'] # TODO Reject on low match count
  end

end

class FoodPage
  attr_reader :name, :full_name, :plant, :nutrition, :poison

  def initialize(json)
    @name = json['nickname']
    @full_name = json['name']
    @plant = json['plant']
    @plant = @plant.intern if @plant
    @nutrition = json['nutrition']
    @poison = json['poison']
  end

end

module Loader

  def self.whitelist
    [PersonPage, PlacePage, WeaponPage, AnimalPage, FoodPage]
  end

  def self.load(json)
    arr = json.collect do |expr|
      begin
        name = Object.const_get "#{expr['nature']}Page"
        name.new expr if whitelist.include? name
      rescue NameError
        nil
      end
    end
    arr.reject &:nil?
  end

end
