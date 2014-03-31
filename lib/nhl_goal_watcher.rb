require 'nhl_goal_watcher/version'
require 'nhl_goal_watcher/goal_watcher'
require 'nhl_goal_watcher/goal'

module NhlGoalWatcher
  LightState = Struct.new(:state, :brightness, :hue, :saturation,
                        :x, :y, :color_temperature, :color_mode)
end
