require 'nhl-goal-watcher'

watcher = GoalWatcher.new(:team => "CHI", :mp3 => "./hawks_goal.mp3")
watcher.start
