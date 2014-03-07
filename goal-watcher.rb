require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'pp'

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
    pid = fork do
      exec 'ruby', './goal.rb'
    end
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

  if response.code == "200"
    body = parse_jsonp(response.body)
    results = JSON.parse(body)
    games = results["games"]

    games.each do |game|
      if game['hta'] == @team || game['ata'] == @team
        unless @game_type
          assign_game_type(game)
        end

        puts "Home Team: #{game['htcommon']}\t#{game['hts']}"
        puts "Away Team: #{game['atcommon']}\t#{game['ats']}"
        puts "Status: #{game['bs']}\n"

        check_scores(game)
      end
    end
  end

  sleep @timeout
  poll_games
end

@team = "CHI"
@timeout = 10

poll_games
