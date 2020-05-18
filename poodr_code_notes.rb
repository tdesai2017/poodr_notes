# Hiding Instance Variables
class Gear
  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring = chainring
    @cog = cog
  end

  def ratio
    chainring / cog.to_f
  end
end

#Struct
Customer = Struct.new(:name, :address) do
  #Has automatically created attr_accessor
  def greeting
    "Hello #{name}!"
  end
end

#Constants can float around in a ruby class
class ConstantTest

  CONSTANTVARIABLE = 'CONSTANT'
  class ConstantClass
  end
  ConstantStruct = Struct.new(:temp_var)

  def initialize
    puts(CONSTANTVARIABLE)
    puts(ConstantClass)
    puts(ConstantStruct.new("temp_var"))
  end
end

# Hiding Info from messy data structures
class RevealingReferences
  attr_reader :wheels

  def initialize(data)
    @wheels = wheelify(data)
  end

  #This was split into two methods so that diameters is no longer doing two different things
  def diameters
    wheels.collect {|wheel| diameter(wheel)}
  end

  def diameter(wheel)
    wheel.rim + (wheel.tire * 2)
  end

  Wheel = Struct.new(:rim, :tire) do 
    #You could put some methods in here if you want
  end

  def wheelify(data)
    data.collect {|cell| Wheel.new(cell[0], cell[1])}
  end
end

#Private methods in Ruby
class SelfTester
  attr_reader :start
  def initialize
    self.print_private
  end

  private

  def print_private
    puts('private')
  end

end

# Calling Static Method from within your own cloass
class Foo
  def self.some_class_method
      puts self
  end

  def some_instance_method
      self.class.some_class_method
  end
end
print "Class method: "
# Foo.some_class_method
# print "Instance method: "

############################################################################################################

#Inherited bikes and parts code - pg 165

class Bicycle
  attr_reader :size, :parts

  def initialize(size:, parts:)
    @size = size
    @parts = parts
  end

  def spares
    parts.spares
  end

end

class Parts
  attr_reader :chain, :tire_size

  def initialize(**opts)
    @chain = opts[:chain]
    @tire_size = opts[:tire_size]
    post_initialize(**opts)
  end

  def spares
    {chain: chain,
    tire_size: tire_size}.merge(local_spares)
  end

  def default_tire_size
    raise NotImplementedError
  end

  #subclasses may override
  def post_initialize(opts)
    nil
  end

  def local_spares
    {}
  end

  def default_chain
    "11-speed"
  end

end

class RoadBikeParts < Parts
  attr_reader :tape_color

  def post_initialize(**opts)
    @tape_color = opts[:tape_color]
  end

  def local_spares
    {tape_color: tape_color}
  end

  def default_tire_size
    "23"
  end

end

class MountainBikeParts < Parts
  attr_reader :front_shock, :rear_shock

  def post_initialize(**opts)
    @front_shock = opts[:front_shock]
    @rear_shock = opts[:rear_shock]
  end

  def local_spares
    { front_shock: front_shock,
      rear_shock: rear_shock}
  end

  def default_tire_size
    "2.1"
  end

end


road_bike = Bicycle.new(size: "L", parts: RoadBikeParts.new(tape_color: "red"))
puts road_bike.size
puts road_bike.spares


mountain_bike = Bicycle.new(size: "L", parts: MountainBikeParts.new(front_shock: "Manitou", rear_shock: "Fox"))
puts mountain_bike.size
puts mountain_bike.spares
#Composed bikes and parts


############################################################################################################

#Composite Bikes and parts code - Pg 182

class Bicycle
  attr_reader :size, :parts

  def initialize(size:, parts:)
    @size = size
    @parts = parts
  end

  def local_spares
    parts.spares
  end

end

require 'forwardable'
class Parts
  extend Forwardable
  def_delegators :@parts, :size, :each
  include Enumerable

  def initialize(parts)
    @parts = parts
  end

  def spares
    #works since parts is an enumerable
    select {|part| part.needs_spare}
  end
end

#Creates Factor to generate "Parts"
require 'ostruct'
module PartsFactory
  def self.build(config:, parts_class: Parts)
    parts_class.new(
      config.collect {|part_config|
        create_part(part_config)})
  end

  #A "Part" is now a struct
  def self.create_part(part_config)
    OpenStruct.new(
      name: part_config[0],
      description: part_config[1],
      needs_spare: part_config.fetch(2, true))
  end
end

road_config = 
[['chain', '11-speed'],
  ['tire_size', '23'],
  ['tape_color', 'red']]

mountain_config = 
[['chain', '11-speed'],
  ['tire_size', '2.1'],
  ['front_shock', 'Manitou'],
  ['rear_shock', 'Fox', false]]
    

  road_bike = Bicycle.new(size: 'L', parts: PartsFactory.build(config: road_config))
  puts road_bike.spares

  mountain_bike = Bicycle.new(size: 'L', parts: PartsFactory.build(config: mountain_config))
  puts mountain_bike.spares