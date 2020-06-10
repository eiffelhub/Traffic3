note
	description: "View for stations"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_STATION_VIEW

inherit

	TRAFFIC_VS_VIEW [TRAFFIC_STATION]
		undefine
			copy,
			is_equal,
			show,
			hide,
			draw
		redefine
			set_highlight_color,
			set_color,
			unhighlight,
			highlight
		end

	DRAWABLE_OBJECT_CONTAINER [DRAWABLE_OBJECT]
		rename
			color as internal_color,
			set_color as set_internal_color,
			make as make_container,
			item as container_item
		export {NONE}
			make_container
		end

create
	make

feature -- Initialization

	make (a_item: TRAFFIC_STATION)  
			-- Initialize view for `a_item'.
		do
			make_container
			item := a_item
			create rectangle.make (create {REAL_COORDINATE}.make ((a_item.location.x-(a_item.width/2).max(5)), (-a_item.location.y-(a_item.breadth/2).max(5))),
									create {REAL_COORDINATE}.make ((a_item.location.x+(a_item.width/2).max(5)), (-a_item.location.y+(a_item.breadth/2).max(5))))
			rectangle.set_color (default_color)
			rectangle.set_edge_color (default_color)
			create text.make (item.name, create {REAL_COORDINATE}.make (a_item.location.x+a_item.width + 5, -a_item.location.y+a_item.breadth+ 5))
			put_last (rectangle)
			put_last (text)
			is_shown := True
			is_highlighted := False
			item.changed_event.subscribe (agent update)
		ensure then
			internal_color_exists: internal_color /= Void
		end

feature -- Status setting

	set_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				else
					rectangle.set_color (default_color)
					rectangle.set_edge_color (default_color)
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					rectangle.set_color (default_highlight_color)
					rectangle.set_edge_color (default_highlight_color)
				end
			end
		end

feature -- Basic operations

	update
			-- Update to reflect changes in item.
		do
			if item.is_highlighted then
				if highlight_color /= Void then
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					rectangle.set_color (default_highlight_color)
					rectangle.set_edge_color (default_highlight_color)
				end
			else
				if color /= Void then
					rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
					rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				else
					rectangle.set_color (default_color)
					rectangle.set_edge_color (default_color)
				end
			end
			rectangle.set_points (    create {REAL_COORDINATE}.make ((item.location.x-(item.width/2).max(5)), (-item.location.y-(item.breadth/2).max(5))),
							create {REAL_COORDINATE}.make ((item.location.x+(item.width/2).max(5)), (-item.location.y+(item.breadth/2).max(5))))
		end

	highlight
			-- Highlight the view.
		do
			if highlight_color /= Void then
				rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
			else
				rectangle.set_color (default_highlight_color)
				rectangle.set_edge_color (default_highlight_color)
			end
			is_highlighted := True
		end

	unhighlight
			-- Unhighlight the view.
		do
			if color /= Void then
				rectangle.set_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				rectangle.set_edge_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
			else
				rectangle.set_color (default_color)
				rectangle.set_edge_color (default_color)
			end
			is_highlighted := False
		end

feature -- Constants

	default_color: EV_COLOR
			-- Default color
		once
			create Result.make_with_8_bit_rgb (100, 100, 100)
		end

	default_highlight_color: EV_COLOR
			-- Default highlight color
		once
			create Result.make_with_8_bit_rgb (255, 62, 150)
		end

feature -- Internals

	rectangle: DRAWABLE_ROUNDED_RECTANGLE

	text: DRAWABLE_TEXT

end
