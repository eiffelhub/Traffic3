note
	description: "View for buildings, subclasses make this class effective"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_BUILDING_VIEW

inherit

	TRAFFIC_VS_VIEW [TRAFFIC_BUILDING]
		undefine
			copy,
			is_equal,
			show,
			hide,
			draw
		end

	DRAWABLE_OBJECT_CONTAINER [DRAWABLE_OBJECT]
		rename
			color as internal_color,
			set_color as set_internal_color,
			make as make_container,
			item as container_item
		export {NONE}
			internal_color,
			set_internal_color,
			make_container
		redefine
			draw_object
		end

feature -- Initialization

	make (a_item: like item)  
			-- Initialize view for `a_item'.
		do
			item := a_item
			make_container
			define
			is_shown := True
			is_highlighted := False
			item.changed_event.subscribe (agent update)
		ensure then
			internal_color_exists: internal_color /= Void
		end

feature -- Constants

	default_color: EV_COLOR
			-- Default color
		once
			create Result.make_with_8_bit_rgb (200, 200, 200)
		end

	default_highlight_color: EV_COLOR
			-- Default highlight color
		once
			create Result.make_with_8_bit_rgb (255, 0, 0)
		end

feature{EV_CANVAS} -- Display

	draw_object
			-- Draws the rectangle.
		do
			if is_shown then
				Precursor
			end
		end

feature {NONE} -- Implementation

	define
			-- Define the objects in the container.
		deferred
		end

end
