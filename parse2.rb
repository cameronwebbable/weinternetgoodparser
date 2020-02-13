require 'rubygems'

require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'watir'

require './espn_config'
require './fantasyplayer'


def get_teams doc
  teams = {}
  teams_div = doc.css('.teams').last
  teams_div.css('.NavSecondary__TextContainer').each do |team|
    owner_name = team.css('.owner-name').first.text
    team_name = team.css(".NavMain__Text").first.text.split(" (").first
    teams[team_name] = owner_name.split.first.capitalize
  end

  teams
end

def get_scores config
  browser = Watir::Browser.new :chrome, headless: true
  browser.goto config.scoreboard_url
  puts 'Waiting for Scoreboard to Load...'
  browser.div(class: "matchupWeekDropdown").wait_until(&:exists?)

  doc = Nokogiri::HTML(browser.html)
  teams = get_teams doc

  scores = doc.css('.matchup-score').map { |matchup| 
    matchup_teams = matchup.css('.ScoreCell__TeamName').map { |m| m.text}
    detail_url = matchup.css('.Scoreboard__Callouts').css('a').attribute('href').value
    matchup_scores = { url: detail_url }
    matchup.css('.ScoreCell__Score').each_with_index { |val, index|
      team_owner = teams[matchup_teams[index]]
      matchup_scores[team_owner] = val.text.to_i
    }

    matchup_scores
  }

  {scores: scores, teams: teams}

end

def get_stomps matchup_scores
  matchup_scores.map { |matchup| 
    if matchup.values.reduce(:-).abs >= 40
      matchup
    end
  }.compact
end

def get_all_player_box config, scores, team_hash
  player_scores = []
  scores.each {|score|
    browser = Watir::Browser.new :chrome, headless: true
    puts config.url_from_relative score[:url]
    browser.goto config.url_from_relative score[:url]
    puts 'Waiting for page to load...'
    browser.tr(class: 'Table2__odd').wait_until(&:exists?)

    doc = Nokogiri::HTML(browser.html)
    teams = doc.css('.teamName').map {|team| team.text}
    puts teams
    doc.css('.mr4').each_with_index { |lineup_div, index|
      owner = teams[index]
      player_scores += lineup_div.css('.Table2__odd').map {|player_row|
        row_info = player_row.css('.Table2__td')
        player_pos = row_info[0].xpath(".//div").attribute('title')
        player_name = row_info[1].xpath(".//div").attribute('title')
        if player_name.nil? || player_name.text == "Player"
          next
        end
        if player_pos.text == "Injured Reserve"
          next
        end
        player_proj = row_info[4].xpath(".//div/span").text
        if player_proj == "--"
          player_proj = 0
        end
        player_actual = row_info[5].xpath(".//div/span").text
        if player_actual == "--"
          player_actual = 0
        end
        FantasyPlayer.new(player_name.text, team_hash[owner], player_pos.text, player_proj, player_actual)
      }.compact
    }
  }

  player_scores

end

def free_agents config
  browser = Watir::Browser.new :chrome, headless: false
  browser.goto config.free_agents_url
  puts config.free_agents_url
  puts 'Waiting for Scoreboard to Load...'
  browser.thead(class: "Table2__sub-header").wait_until(&:exists?)
  browser.divs(class: 'jsx-2810852873 table--cell total tar header sortable').last.click
  sleep 4
  #Table2__th
  # doc = Nokogiri::HTML(browser.html)
  # sort = doc.css('.Table2__th').last.click
end

def gimmeh_stomps 
  stomps = []
  ["1", "2","3","4","5","6","7","8", "9", "10", "11", "12", "13"].each { |current_week|
    espn_config = ESPNConfig.new("197012", current_week)

    scores_data = get_scores espn_config
    scores = scores_data[:scores]
    teams = scores_data[:teams]
    
    week_stomps = get_stomps scores.map { |m| m.select{|x| x != :url} }
    week_stomps << current_week
    stomps = stomps + week_stomps
  }

  stomps
end 
current_week = "14"
espn_config = ESPNConfig.new("197012", current_week)

scores_data = get_scores espn_config
puts "Retreived Score Data"
scores = scores_data[:scores]
teams = scores_data[:teams]

stomps = get_stomps scores.map { |m| m.select{|x| x != :url} }
matchup_urls = scores.map {|m| m.select {|x| x == :url} }
puts "Getting player info"
players = get_all_player_box espn_config, scores, teams

most = players.sort {|a,b| a.actual.to_i <=> b.actual.to_i}.select{|player| player.position != "Bench"}.reverse[0, 5]
most_bench = players.sort {|a,b| a.actual.to_i <=> b.actual.to_i}
most_bench = most_bench.select {|p| p.position == 'Bench'}.reverse[0, 5]
bad = players.select {|player| player.actual.to_i < 0 && player.position != "Bench"}

# puts "Scores"
#puts (scores.map { |m| m.select{|x| x != :url} })
puts "Stomps"
puts gimmeh_stomps
# puts "Most"
# puts most
# puts "Bad"
# puts bad
# puts "Most Bench"
# puts most_bench

#puts free_agents espn_config
