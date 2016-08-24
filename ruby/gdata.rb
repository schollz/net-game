
class GData
  attr_reader :node, :map

  def initialize(everything)
    @arr = everything.clone
    @node = nil
    @bridges = [] # TODO Store bridges, etc in a metadata part of the system.txt file for later.
    @map = nil
    @creatures = CreatureSet.new
    @spawners = SpawnerSet.new
    @quests = QuestSet.new
  end

  # Assigns the singular node
  def node=(val)
    case val
    when Node, NilClass
      @node = val
    end
  end

  # Checks if the list of bridges is non-empty
  def has_bridge?
    not @bridges.empty?
  end

  # Gets (and removes) a bridge, if available
  def get_a_bridge
    if has_bridge?
      result = @bridges.sample
      @bridges = @bridges.delete result
      result
    end
  end

  # Adds bridges to the list of available bridges
  def add_bridges(*bridges)
    @bridges.push(*bridges)
  end

  # Iterates over the data in the array. The block should return
  # truthy if it "consumes" the element, in which case the element
  # will be removed
  def consume_each(&block)
    @arr = @arr.reject(&block)
  end

  # Loads a creature into the CreatureSet, using load_from_page
  def load_creature(elem)
    @creatures.load_from_page elem
  end

  # Checks whether we have any creatures
  def has_creature?
    not @creatures.empty?
  end

  # Iterates over the creatures in the creature set
  def each_creature(&block)
    @creatures.each(&block)
  end

  # Checks whether we have any spawners
  def has_spawner?
    not @spawners.empty?
  end

  # Adds one or more spawners to the spawner set
  def add_spawners(*elems)
    @spawners.push(*elems)
  end

  # Iterates over the spawners in the spawner set
  def each_spawner(&block)
    @spawners.each(&block)
  end

  # Adds one or more quests to the quest set
  def add_quests(*elems)
    @quests.push(*elems)
  end

  # Iterates over the quests in the quest set
  def each_quest(&block)
    @quests.each(&block)
  end

  # Select all nodes on the map for which the predicate returns truthy
  def select_nodes(&block)
    @map.select(&block)
  end

  # Convert the node into a map and add the locations to it
  def node_to_map
    new_map = Map.new @node.expand_to_map(gdata: self)
    if map.nil?
      @map = new_map
    else
      # TODO Connect the old and the new using connectors
      new_map.each { |loc| map.push loc }
    end
  end

  # Return the generator data in an appropriate output list format
  def result_structure
    AlphaStructure.new map, @creatures, @spawners, @quests, get_meta_data
  end

  # Return the metadata object that will be stored with the result structure
  def get_meta_data
    MetaData.new(:':curr-id' => Node.current_id,
                 :':curr-quest-flag' => QuestMaker.current_quest_flag)
  end

  def self.from_sxp(arg)
    map, creatures, spawners, quests, meta = arg
    reloader = Reloader.instance
    meta = reloader.load meta
    GData.new([]).tap do |gdata|
      gdata.instance_variable_set :@map, reloader.load(map)
      gdata.instance_variable_set :@creatures, reloader.load(creatures)
      gdata.instance_variable_set :@spawners, reloader.load(spawners)
      gdata.instance_variable_set :@quests, reloader.load(quests)
      Node.current_id = meta[:':curr-id']
      QuestMaker.current_quest_flag = meta[:':curr-quest-flag']
    end
  end

end

class AlphaStructure

  def initialize(map, creatures, spawners, quests, meta)
    @map = map
    @creatures = creatures
    @spawners = spawners
    @quests = quests
    @meta = meta
  end

  def to_sxp
    [:alpha, @map, @creatures, @spawners, @quests, @meta].to_sxp
  end

end
