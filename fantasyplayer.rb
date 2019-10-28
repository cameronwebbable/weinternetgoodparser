class FantasyPlayer
  attr_accessor :name
  attr_accessor :owner
  attr_accessor :position
  attr_accessor :projected
  attr_accessor :actual
  
  def initialize(name, owner, position, projected, actual)
    @name = name
    @owner = owner
    @position = position
    @projected = projected
    @actual = actual

  end

  def <=>(other)
    @actual.to_i <=> other.actual.to_i
  end

  def to_s
    [@name, @owner, @position, (@actual + ' pts')].join(', ')
  end
end
