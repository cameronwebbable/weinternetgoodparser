class ESPNConfig
  BASE_URL = "https://fantasy.espn.com"
  LEAGUE_CONSTANT = "league"
  LEAGUE_ID_CONSTANT = "leagueId"
  MATCHUP_PERIOD_ID_CONSTANT = "matchupPeriodId"
  
  def initialize league_id, matchup_period, season_id = 2019, sport = "football"
    @league_id = league_id    
    @matchup_period = matchup_period 
    @season_id = season_id
    @sport = sport
  end

  def scoreboard_url
    #https://fantasy.espn.com/football/league/scoreboard?leagueId=197012&matchupPeriodId=7
    url_builder = generate_url "scoreboard"
    url_builder + (parameterize league_week_params)
  end

  def free_agents_url
    #https://fantasy.espn.com/football/players/add?leagueId=197012
    ([BASE_URL, @sport, LEAGUE_CONSTANT, page_type].join '/')
  end

  def boxscore_url
    ([BASE_URL, @sport, "boxscore"]. join '/')

  end
  
  def standings_url
    #https://fantasy.espn.com/football/league/standings?leagueId=197012&matchupPeriodId=7
    url_builder = generate_url "standings"
    url_builder + (parameterize league_week_params)
  end

  ## Bunch of helper methods

  def generate_url page_type
    #https://fantasy.espn.com/football/league/#{page_type}
    ([BASE_URL, @sport, LEAGUE_CONSTANT, page_type].join '/')
  end
  
  def league_week_params
    [[LEAGUE_ID_CONSTANT, @league_id], [MATCHUP_PERIOD_ID_CONSTANT, @matchup_period]]
  end

  def parameterize get_params
    #Returns string params from array, eg `?leagueId=197012&matchupPeriodId=7&`

    param_builder = "?"
    get_params.each do |param|
      param_builder += "#{param[0]}=#{param[1]}&"
    end
    param_builder
  end
end