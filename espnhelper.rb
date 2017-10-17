require 'open-uri'
require 'rubygems'
require 'nokogiri'

class ESPNHelper
  BASE_URL = "http://games.espn.com"
  MATCHUP_URL = "http://games.espn.com/ffl/scoreboard?leagueId=197012&matchupPeriodId="
  FREE_AGENT_URL = "http://games.espn.com/ffl/leaders?leagueId=197012&teamId=1&avail=1&scoringPeriodId="
  STANDINGS_URL = "http://games.espn.com/ffl/standings?leagueId=197012&seasonId=2017"

  def initialize()
  end

  def scoresForWeek(week=1):
    currentWeekURL = MATCHUP_URL + week
  end

  def topStarters():
  end

  def topFreeAgents(week=1):
    freeAgentsURL = FREE_AGENT_URL + week
  end

  def topBenchPlayers():
  end

  def topBadPlayers():
  end

  def bigDefeats():
  end

  def powerRankings():
  end

  def nextWeekMatchups():
  end

end
