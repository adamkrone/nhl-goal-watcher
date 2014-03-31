require 'hue'
require 'parallel'

module NhlGoalWatcher
  class Goal
    def initialize(args)
      @mp3 = args[:mp3]
    end

    def score
      client = Hue::Client.new

      play_mp3

      Parallel.each(client.lights) do |light|
        # Save current brightness/hue
        saved_light_state = save_light_state(light)

        sleep 3

        setup_light(light)

        sleep 1

        flash_light(light)
        revert_light(light, saved_light_state)
      end
    end

    def play_mp3
      pid = fork do
        sleep 2
        exec 'afplay', @mp3
      end
    end

    def save_light_state(light)
      return LightState.new(light.on?, light.brightness, light.hue, light.saturation,
                     light.x, light.y, light.color_temperature, light.color_mode)
    end

    def setup_light(light)
        light.set_state({
          :on => true,
          :brightness => 255,
          :hue => 65535,
          :transitiontime => 10})
    end

    def flash_light(light)
      27.times do |i|
        light.set_state({
          :brightness => 0,
          :transitiontime => 10})

        sleep 1

        light.set_state({
          :brightness => 255,
          :transitiontime => 10})

        sleep 1
      end
    end

    def revert_light(light, saved_light_state)
      light.set_state({
        :on => saved_light_state.state,
        :brightness => saved_light_state.brightness,
        :hue => saved_light_state.hue,
        :saturation => saved_light_state.saturation,
        :x => saved_light_state.x,
        :y => saved_light_state.y,
        :color_temperature => saved_light_state.color_temperature,
        :color_mode => saved_light_state.color_mode})
    end
  end
end
