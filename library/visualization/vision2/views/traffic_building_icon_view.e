note
	description: "Iconic view of a building (for special buildings such as landmarks)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_BUILDING_ICON_VIEW

inherit

	TRAFFIC_BUILDING_VIEW
		redefine
			set_color,
			set_highlight_color,
			highlight,
			unhighlight
		end

	KL_SHARED_FILE_SYSTEM

create
	make_with_filename

feature -- Initialization

	make_with_filename (a_item: like item; a_filename: STRING)  
			-- Initialize view for `a_item'.
		require
			a_filename_valid: a_filename /= Void and then not a_filename.is_empty
			a_fileexists: file_system.is_file_readable (a_filename)
		local
			pix: EV_PIXMAP
		do
			item := a_item
			make_container
			create pix
			pix.set_with_named_file (a_filename)
			create icon.make (pix, create {REAL_COORDINATE}.make (item.center.x, item.center.y))
			item.set_size (pix.width, item.height, pix.height)
			create rectangle.make  (create {REAL_COORDINATE}.make (item.corner_1.x-5, -item.corner_1.y+5),
							create {REAL_COORDINATE}.make (item.corner_3.x+5, -item.corner_3.y-5))
			rectangle.set_edge_color (default_color)
			rectangle.set_color (default_color)
			icon.set_position (create {REAL_COORDINATE}.make (item.corner_1.x, -item.corner_3.y))
			put_last (rectangle)
			put_last (icon)
			is_shown := True
			is_highlighted := False
			item.changed_event.subscribe (agent update)
		ensure then
			internal_color_exists: internal_color /= Void
		end

	define
			-- Do nothing.
		do
		end

feature -- Basic operations

	update
			-- Update view to represent item.
		do
			if item.is_spotlighted then
				highlight
			else
				unhighlight
			end
			rectangle.set_points (    create {REAL_COORDINATE}.make (item.corner_1.x-5, -item.corner_1.y+5),
							create {REAL_COORDINATE}.make (item.corner_3.x+5, -item.corner_3.y-5))
			icon.set_position (create {REAL_COORDINATE}.make (item.corner_1.x, -item.corner_3.y))
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

	icon: DRAWABLE_PIXMAP

	rectangle: DRAWABLE_RECTANGLE

end
