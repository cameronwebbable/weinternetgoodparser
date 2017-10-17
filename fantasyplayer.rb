class FantasyPlayer
  attr_accessor :name
  attr_accessor :points
  attr_accessor :owner

  def initialize(playerNode, owner)
    @name = name
    @points = points
    @owner = owner
    nameNode = playerNode.xpath(".//td[@class='playertablePlayerName']")
    @name = ""
    if !nameNode.nil? && nameNode.length > 0
      @name = nameNode[0].text.strip.split(/(?:[[:space:]][[:space:]]+|\t)/)[0]
    end
    @points = playerNode.xpath(".//td[@class='playertableStat appliedPoints appliedPointsProGameFinal']").text || "0"
    @owner = owner

  end

  def <=>(other)
    @points.to_i <=> other.points.to_i
  end

  def to_s
    @name + ", " + @points + " points (" + @owner + ")"
  end
end
