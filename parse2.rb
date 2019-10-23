require 'rubygems'

require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'watir'

require './espn_config'

def get_teams doc
  teams = {}
  teams_div = doc.css('.teams').last
  teams_div.css('.NavSecondary__TextContainer').each do |team|
    owner_name = team.css('.owner-name').first.text
    team_name = team.css(".NavMain__Text").first.text.split(" (").first
    teams[team_name] = owner_name
  end

  teams
end

def get_scores espn_config
  browser = Watir::Browser.new :chrome, headless: true
  browser.goto espn_config.scoreboard_url
  puts 'Waiting for Scoreboard to Load...'
  browser.div(class: "matchupWeekDropdown").wait_until(&:exists?)

  doc = Nokogiri::HTML(browser.html)
  teams = get_teams doc

  doc.css('.matchup-score').map { |matchup| 
    matchup_teams = matchup.css('.ScoreCell__TeamName').map { |m| m.text}
    detail_url = matchup.css('.Scoreboard__Callouts').css('a').attribute('href').value
    matchup_scores = { url: detail_url }
    matchup.css('.ScoreCell__Score').each_with_index { |val, index|
      matchup_scores[matchup_teams[index]] = val.text.to_i
    }

    matchup_scores
  }

end

def get_stomps matchup_scores
  matchup_scores.map { |matchup| 
    if matchup.values.reduce(:-) >= 40
      matchup
    end
  }.compact
end

def get_high_low_bench_points scores
  
end

current_week = "7"
espn_config = ESPNConfig.new("197012", current_week)

scores = get_scores espn_config
puts get_stomps scores.map { |m| m.select{|x| x != :url} }
