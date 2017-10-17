require 'open-uri'
require 'rubygems'
require 'nokogiri'

require './fantasyplayer'

url = "http://games.espn.com/ffl/scoreboard?leagueId=197012&matchupPeriodId="
freeAgentsURL = "http://games.espn.com/ffl/leaders?leagueId=197012&teamId=1&avail=1&scoringPeriodId="
standingsUrl = "http://games.espn.com/ffl/standings?leagueId=197012&seasonId=2017"
baseURL = "http://games.espn.com"
print "Enter Week: "
week = gets.chomp

currentWeekURL = url + week
freeAgentsURL += week
followingWeek = url + (week.to_i + 1).to_s
puts
quickStatsURLS = []
nextWeekQuickStatsURLS = []

doc = Nokogiri::HTML(open(currentWeekURL))
doc.css('.boxscoreLinks a').each do |link|
  href = link.attribute('href').value
  if href.include?('quick')
    quickStatsURLS.push(baseURL + href)
  end
end

startingPlayers = []
benchPlayers = []
curbStomps = []

#Stats from each match up
puts "This Week's Scores"
quickStatsURLS.each do | statsURL |
  quickDoc = Nokogiri::HTML(open(statsURL))

  p = quickDoc.xpath('//div[@class="teamInfoOwnerData"]')

  scores = quickDoc.xpath('//div[@class="danglerBox totalScore"]')
  ownerA = p[0].text.split(" ")[0]
  ownerB = p[1].text.split(" ")[0]
  ownerAScores = scores[0].text.to_i
  ownerBScores = scores[1].text.to_i

  if (ownerAScores > ownerBScores)
    puts "#{ownerA} over #{ownerB} (#{ownerAScores} pts - #{ownerBScores} pts)"
  elsif (ownerBScores > ownerAScores)
    puts "#{ownerB} over #{ownerA} (#{ownerBScores} pts - #{ownerAScores} pts)"
  else
    puts "#{ownerA} tied #{ownerB} (#{ownerAScores} pts - #{ownerBScores} pts)"
  end

  pointDiff = ownerAScores - ownerBScores

  if pointDiff.abs >= 40
    #We want first names
    if pointDiff < 0
      curbStomps.push "#{ownerB} (#{scores[1].text.to_i} pts) over #{ownerA} (#{scores[0].text.to_i} pts) - #{pointDiff.abs} point margin of victory"
    else
      curbStomps.push "#{ownerA} (#{scores[0].text.to_i} pts) over #{ownerB} (#{scores[1].text.to_i} pts) - #{pointDiff.abs} point margin of victory"
    end
  end

  teamBox = quickDoc.xpath('//table[@class="playerTableTable tableBody"]').each_with_index do |team, index|
    #There's 2 seperate paths to get players for each team, Cuz ESPN.
    teamPlayersA = team.xpath(".//tr[@class='pncPlayerRow playerTableBgRow0']", ".//tr[@class='pncPlayerRow playerTableBgRow1']")
    teamPlayersA.each do |player|
      owner = p[index].text.split(" ")[0]
      fantasyPlayer = FantasyPlayer.new(player, owner)
      startingPlayers.push(fantasyPlayer)
    end
  end

  benchTeam = quickDoc.xpath('//table[@class="playerTableTable tableBody hideableGroup"]').each_with_index do |team, index|
    teamPlayersA = team.xpath(".//tr[@class='pncPlayerRow playerTableBgRow0']", ".//tr[@class='pncPlayerRow playerTableBgRow1']")
    teamPlayersA.each do |player|
      owner = p[index].text.split(" ")[0]
      fantasyPlayer = FantasyPlayer.new(player, owner)
      benchPlayers.push(fantasyPlayer)
    end
  end
end
puts
puts "Top Starters"
puts startingPlayers.sort {|a,b| a.points.to_i <=> b.points.to_i }.reverse[0, 5]
puts
puts "Top Free Agents"
freeAgentsDoc = Nokogiri::HTML(open(freeAgentsURL))
freeAgentsDoc.xpath('//tr[contains(@class,"pncPlayerRow")]')[0,5].each do |freeAgentsNode|
  #Name/Position
  print freeAgentsNode.xpath(".//td[@class='playertablePlayerName']").text
  print " "
  #Points
  puts freeAgentsNode.xpath(".//td[@class='playertableStat appliedPoints appliedPointsProGameFinal']").text

end

puts
puts "Top Bench Players"
puts benchPlayers.sort {|a,b| a.points.to_i <=> b.points.to_i }.reverse[0, 5]
puts
puts "Top Flaming Pieces of Trash"
crappyPlayers = startingPlayers.select do |player|
  player.points.to_i < 0
end
if crappyPlayers.length == 0
  puts "None"
else
  puts crappyPlayers.sort {|a,b| a.points.to_i <=> b.points.to_i }
end
puts
puts "Curbstomps"
if curbStomps.length == 0
  puts "None"
else
  puts curbStomps
end
puts

### Power Rankings ###
puts "Power Rankings"
rankingsDoc = Nokogiri::HTML(open(standingsUrl))
rankingsDoc.xpath('//tr[contains(@class,"sortableRow")]').each_with_index do |rankingsNode, index|
  #Name/Position
  print "#{index + 1}) "
  print /\(\w*/.match(rankingsNode.xpath(".//td")[0].text).to_s.split("(")[1]
  print " "
  print rankingsNode.xpath(".//td[@class='sortableDIV']").text.split("-")[0,2].join("-")
  puts " "
  #Points
  # puts freeAgentsNode.xpath(".//td[@class='playertableStat appliedPoints appliedPointsProGameFinal']").text

end
puts

followingWeekDoc = Nokogiri::HTML(open(followingWeek))
followingWeekDoc.css('.boxscoreLinks a').each do |link|
  href = link.attribute('href').value
  if href.include?('quick')
    nextWeekQuickStatsURLS.push(baseURL + href)
  end
end

puts "Next Week's Matchups"
nextWeekQuickStatsURLS.each do | statsURL |
  quickDoc = Nokogiri::HTML(open(statsURL))

  p = quickDoc.xpath('//div[@class="teamInfoOwnerData"]')

  scores = quickDoc.xpath('//div[@class="danglerBox totalScore"]')
  ownerA = p[0].text.split(" ")[0]
  ownerB = p[1].text.split(" ")[0]
  puts "#{ownerA} vs #{ownerB}"
end
