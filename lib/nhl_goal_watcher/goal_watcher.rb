require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

require 'nhl_goal_watcher/goal'

module NhlGoalWatcher
  class GoalWatcher
    attr_reader :team

    def initialize(args)
      @team = args[:team]
      @timeout = args[:timeout] || 30
      @mp3 = args[:mp3]
      @goal = NhlGoalWatcher::Goal.new(:mp3 => @mp3)
    end

    def start
      poll_games
    end

    private

    def parse_jsonp(jsonp)
      return jsonp.gsub(/\AloadScoreboard\(|\)\Z/, '')
    end

    def assign_game_type(game)
      puts "Assigning game type..."
      @game_type = game['hta'] == @team ? "home" : "away"
      puts "#{@team} is playing a(n) #{@game_type} game"
    end

    def check_scores(game)
      score = @game_type == "home" ? game['hts'] : game['ats']

      if @team_score && score > @team_score
        puts "GOOOOOOOOOAAAAAAAAAAAL!!!"
        @goal.score
      end

      @team_score = score
    end

    def poll_games
      time = Time.new
      date = time.strftime('%Y-%m-%d')
      uri = URI.parse("http://live.nhle.com/GameData/GCScoreboard/#{date}.jsonp")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      parse_response(response)

      sleep @timeout
      poll_games
    end

    def parse_response(response)
      if response.code == "200"
        body = parse_jsonp(response.body)
        results = JSON.parse(body)
        games = results["games"]

        check_games(games)
      end
    end

    def check_games(games)
      games.each do |game|
        if game['hta'] == @team || game['ata'] == @team
          unless @game_type
            assign_game_type(game)
          end

          show_game_status(game)
          check_scores(game)
        end
      end
    end

    def show_game_status(game)
      puts "Home Team: #{game['htcommon']}\t#{game['hts']}"
      puts "Away Team: #{game['atcommon']}\t#{game['ats']}"
      puts "Status: #{game['bs']}\n"
    end
  end
end
