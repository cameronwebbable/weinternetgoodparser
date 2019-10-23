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

  doc.css('.matchup-teams-score').map { |matchup| 
    matchup_teams = matchup.css('.ScoreCell__TeamName').map { |m| m.text}
    matchup_scores = {}
    matchup.css('.ScoreCell__Score').each_with_index { |val, index|
      matchup_scores[matchup_teams[index]] = val.text
    }

    matchup_scores
  }

end

current_week = "7"
espn_config = ESPNConfig.new("197012", current_week)

puts get_scores espn_config

