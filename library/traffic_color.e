note
	description: "Color objects (independent of the visualization to be used, vision2 or em)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_COLOR

create

	make_black, make_white, make_with_rgb

feature -- Initialization

	make_black
			-- Create a black color.
		do
			set_red (0)
			set_green (0)
			set_blue (0)
		ensure
			red_set: red = 0
			green_set: green = 0
			blue_set: blue = 0
		end

	make_with_rgb (red_value, green_value, blue_value: INTEGER)
			-- Create color with `red_value', `green_value' and `blue_value'.
		require
			red_value_in_range: 0 <= red_value and red_value <= 255
			green_value_in_range: 0 <= green_value and green_value <= 255
			blue_value_in_range: 0 <= blue_value and blue_value <= 255
		do
			set_red (red_value)
			set_green (green_value)
			set_blue (blue_value)
		ensure
			red_set: red = red_value
			green_set: green = green_value
			blue_set: blue = blue_value
		end

	make_white
			-- Create a white color
		do
			set_red (255)
			set_green (255)
			set_blue (255)
		ensure
			red_set: red = 255
			green_set: green = 255
			blue_set: blue = 255
		end

feature -- Access

	red: INTEGER
			-- Red spectre of the color

	green: INTEGER
			-- Green spectre of the color

	blue: INTEGER
			-- Blue spectre of the color

feature -- Element change

	set_red (a_value: INTEGER)
			-- Set red spectre of the color to `a_value'
		require
			a_value_in_range: 0 <= a_value and a_value <= 255
		do
			red := a_value
		ensure
			red_set: red = a_value
		end

	set_green (a_value: INTEGER)
			-- Set green spectre of the color to `a_value'
		require
			a_value_in_range: 0 <= a_value and a_value <= 255
		do
			green := a_value
		ensure
			green_set: green = a_value
		end

	set_blue (a_value: INTEGER)
			-- Set blue spectre of the color to `a_value'
		require
			a_value_in_range: 0 <= a_value and a_value <= 255
		do
			blue := a_value
		ensure
			blue_set: blue = a_value
		end

	set_rgb (red_value, green_value, blue_value: INTEGER)
			-- Set red, green and blue values
		require
			red_value_in_range: 0 <= red_value and red_value <= 255
			green_value_in_range: 0 <= green_value and green_value <= 255
			blue_value_in_range: 0 <= blue_value and blue_value <= 255
		do
			set_red (red_value)
			set_green (green_value)
			set_blue (blue_value)
		ensure
			red_set: red = red_value
			green_set: green = green_value
			blue_set: blue = blue_value
		end

invariant

	red_in_range: 0 <= red and red <= 255
	green_in_range: 0 <= green and green <= 255
	blue_in_range: 0 <= blue and blue <= 255

end
