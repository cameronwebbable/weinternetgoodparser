require 'rubygems'
require 'bundler/setup'

require 'open-uri'
require 'nokogiri'
require 'watir'

require './espn_config'

#maybe we'll just eventually detect it
current_week = 7

e = ESPNConfig.new("197012", "7")

matchup_period = 7
puts e.scoreboard_url
puts e.standings_url


browser = Watir::Browser.new :chrome, headless: true
browser.goto e.scoreboard_url
puts 'Waiting for Scoreboard to Load...'
browser.div(class: "player-score").wait_until(&:exists?)
puts doc = Nokogiri::HTML(browser.html)
