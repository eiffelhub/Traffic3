note
	description: "Simple view for buildings (grey rectangle)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_BUILDING_SIMPLE_VIEW

inherit

	TRAFFIC_BUILDING_VIEW
		redefine
			set_color,
			set_highlight_color,
			highlight,
			unhighlight
		end

create
	make

feature -- Initialization

	define  
			-- Define contents of the container.
		do
			create rectangle.make  (create {REAL_COORDINATE}.make (item.corner_1.x, -item.corner_1.y),
							create {REAL_COORDINATE}.make (item.corner_3.x, -item.corner_3.y))
			put_last (rectangle)
			rectangle.set_edge_color (default_color)
			rectangle.set_color (default_color)
		end

feature -- Basic operations

	update
			-- Update view to represent item.
		do
			if item.is_spotlighted then
				if highlight_color /= Void then
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					rectangle.set_edge_color (default_highlight_color)
					rectangle.set_color (default_highlight_color)
				end
			else
				if color /= Void then
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				else
					rectangle.set_edge_color (default_color)
					rectangle.set_color (default_color)
				end
			end
			rectangle.set_points (    create {REAL_COORDINATE}.make (item.corner_1.x, -item.corner_1.y),
							create {REAL_COORDINATE}.make (item.corner_3.x, -item.corner_3.y))

		end

	set_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			color := a_color
			if not item.is_spotlighted then
				if color /= Void then
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				else
					rectangle.set_edge_color (default_color)
					rectangle.set_color (default_color)
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			highlight_color := a_color
			if item.is_spotlighted then
				if highlight_color /= Void then
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					rectangle.set_edge_color (default_highlight_color)
					rectangle.set_color (default_highlight_color)
				end
			end
		end

	highlight
			-- Highlight the view.
		do
			if highlight_color /= Void then
				rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
			else
				rectangle.set_edge_color (default_highlight_color)
				rectangle.set_color (default_highlight_color)
			end
			is_highlighted := True
		end

	unhighlight
			-- Unhighlight the view.
		do
			if color /= Void then
				rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
			else
				rectangle.set_edge_color (default_color)
				rectangle.set_color (default_color)
			end
			is_highlighted := False
		end

feature -- Access

	rectangle: DRAWABLE_RECTANGLE
end
