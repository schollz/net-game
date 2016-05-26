
require 'forwardable'
require 'sxp'

class Map
  extend Forwardable
  include Enumerable

  def_delegators :@ary, :each, :push

  def initialize(ary = [])
    @ary = ary
  end

  def to_ary
    @ary
  end

  def to_a
    to_ary
  end

  def to_sxp
    ([:map] + @ary).to_sxp
  end

  def [](val)
    @ary.find { |x| x.id == val }
  end

  def put_somewhere(obj, type = Object, &block)
    block = proc { true } unless block
    weight = Proc.new { |x| 1 / (x.count_items(type) + 1) }
    total = @ary.map( &weight ).reduce(:+)
    num = rand total
    result = @ary.detect do |x|
      next unless block.call x
      num -= weight.(x)
      num <= 0
    end
    if result
      result.push obj
      true
    else
      false
    end
  end

end

class Location
  extend Forwardable
  include Enumerable

  attr_reader :id, :name, :country_name

  def_delegators :@contents, :each, :[], :[]=, :push, :delete, :pop
  def_delegator :@links, :each, :each_link

  def initialize(id, name, country_name, valid_creatures = nil)
    @id = id
    @name = name
    @country_name = country_name
    @contents = []
    @links = []
    @valid_creatures = valid_creatures
  end

  def has_creatures?
    not @creatures.empty?
  end

  def can_have_creatures?
    not @valid_creatures.nil?
  end

  def can_have?(x)
    @valid_creatures === x
  end

  def long_name
    if @country_name
      "#{@name}, #{@country_name}"
    else
      @name
    end
  end

  def add_link(x)
    @links.push x unless @links.include? x
  end

  def remove_link(x)
    @links.delete x
  end

  def civilized?
    not can_have_creatures?
  end

  def to_sxp
    prefix = [:location, @id, @name]
    country = @country_name ? [:':country', @country_name] : []
    links = [:':links', @links.dup]
    contents = [:':contents', @contents.dup]
    civilized = [:':civilized', civilized?]
    (prefix + country + links + contents + civilized).to_sxp
  end

  def count_items(type = Item)
    self.count { |x| x.kind_of? type }
  end

end
