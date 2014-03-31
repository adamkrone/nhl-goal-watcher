require 'nhl_goal_watcher'

watcher = NhlGoalWatcher::GoalWatcher.new(:team => "CHI", :mp3 => "./hawks_goal.mp3")
watcher.start
