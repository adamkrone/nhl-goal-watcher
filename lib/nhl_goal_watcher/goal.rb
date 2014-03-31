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
        saved_state = light.on?
        saved_brightness = light.brightness
        saved_hue = light.hue
        saved_saturation = light.saturation
        saved_x = light.x
        saved_y = light.y
        saved_color_temperature = light.color_temperature
        saved_color_mode = light.color_mode

        sleep 3

        setup_light(light)

        sleep 1

        flash_light(light)
        revert_light(light,
                     saved_state,
                     saved_brightness,
                     saved_hue,
                     saved_saturation,
                     saved_x,
                     saved_y,
                     saved_color_temperature,
                     saved_color_mode)
      end
    end

    def play_mp3
      pid = fork do
        sleep 2
        exec 'afplay', @mp3
      end
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

    def revert_light(light, saved_state, saved_brightness, saved_hue,
                     saved_saturation, saved_x, saved_y,
                     saved_color_temperature, saved_color_mode)
      light.set_state({
        :on => saved_state,
        :brightness => saved_brightness,
        :hue => saved_hue,
        :saturation => saved_saturation,
        :x => saved_x,
        :y => saved_y,
        :color_temperature => saved_color_temperature,
        :color_mode => saved_color_mode})
    end
  end
end
