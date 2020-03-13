indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_MOVING_VIEW [G -> TRAFFIC_MOVING]

inherit

	TRAFFIC_2D_VIEW [G]
		undefine
			default_create,
			out,
			set_x_y,
			publish_mouse_event
		end

	EM_CIRCLE
		rename
			make as make_circle
		redefine
			draw
		end

create
	make

feature -- Initialization

	make (a_item: like item) is
			-- Set `item' to `a_item'.
		do
			item := a_item
			is_highlighted := False
			make_circle (create {EM_VECTOR_2D}.make (item.position.x-5, item.position.y-5), 5)
			set_fill_color (default_color)
			set_line_color (default_color)
		end

feature -- Element change

	set_color (a_color: TRAFFIC_COLOR) is
			-- Set `color' to `a_color'. May also be Void.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					set_fill_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
					set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
				else
					set_fill_color (Default_color)
					set_line_color (Default_color)
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR) is
			-- Set `highlight_color' to `a_color'. May also be Void.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					set_fill_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					set_fill_color (default_highlight_color)
					set_line_color (default_highlight_color)
				end
			end
		end

	highlight is
			-- Highlight the view.
		do
			is_highlighted := True
			if highlight_color /= Void then
				set_fill_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
			else
				set_fill_color (default_highlight_color)
				set_line_color (default_highlight_color)
			end
		end

	unhighlight is
			-- Unighlight the view.
		do
			is_highlighted := False
			if color /= Void then
				set_fill_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
				set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
			else
				set_fill_color (default_color)
				set_line_color (default_color)
			end
		end

feature -- Constants

	Default_color: EM_COLOR is
			-- Default color
		once
			create Result.make_black
		end

	Default_highlight_color: EM_COLOR is
			-- Default highlight color
		once
			create Result.make_with_rgb (255, 0, 0)
		end

feature -- Drawing

	draw (drawing_interface: EM_SURFACE) is
			-- Draw `Current' using `drawing_interface'.
		do
			set_x_y (item.position.x.floor, item.position.y.floor)
			Precursor (drawing_interface)
		end
end
