note
	description: "View for moving items such as trams, passengers, etc."
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_MOVING_VIEW [G->TRAFFIC_MOVING]

inherit

	TRAFFIC_VS_VIEW [G]
		undefine
			invalidate
		end

	DRAWABLE_CIRCLE
		rename
			color as internal_color,
			set_color as set_internal_color,
			make as make_circle
		export {NONE}
			internal_color,
			set_internal_color,
			make_circle
		redefine
			invalidate,
			draw_object
		end

create
	make

feature -- Initialization

	make (a_item: like item)  
			-- Initialize view for `a_item'.
		do
			item := a_item
			make_circle (create {REAL_COORDINATE}.make (a_item.location.x, -a_item.location.y))
			set_diameter (10)
			set_internal_color (default_color)
			enable_filled
			is_shown := True
			is_highlighted := False
		ensure then
			internal_color_exists: internal_color /= Void
		end

feature -- Basic operations

	update
			-- Update to reflect changes in city item.
		do
			if item.is_highlighted then
				highlight
			else
				unhighlight
			end
		end

feature -- Constants

	default_color: EV_COLOR
			-- Default color
		once
			create Result.make_with_8_bit_rgb (255, 255, 0)
		end

	default_highlight_color: EV_COLOR
			-- Default highlight color
		once
			create Result.make_with_8_bit_rgb (255, 0, 0)
		end

feature {NONE} -- Implementation

	draw_object
			-- Draw the circle.
		do
			set_center (create {REAL_COORDINATE}.make (item.location.x, -item.location.y))
			Precursor
		end

	invalidate
			-- Some property of `Current' has changed.
		do
			is_valid := False
		end

end
