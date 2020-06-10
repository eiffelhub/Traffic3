note
	description: "Deferred class for all vision2 city item views"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_VS_VIEW [G]

inherit

	TRAFFIC_VIEW [G]

	DRAWABLE_OBJECT
		rename
			color as internal_color,
			set_color as set_internal_color
		end

feature -- Obsolete

	is_highlighted: BOOLEAN

feature -- Basic operations

	highlight  
			-- Highlight the view.
		do
			if highlight_color /= Void then
				set_internal_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
			else
				set_internal_color (default_highlight_color)
			end
			is_highlighted := True
		end

	unhighlight
			-- Unhighlight the view.
		do
			if color /= Void then
				set_internal_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
			else
				set_internal_color (default_color)
			end
			is_highlighted := False
		end

	set_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					set_internal_color (create {EV_COLOR}.make_with_8_bit_rgb (color.red, color.green, color.blue))
				else
					set_internal_color (default_color)
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					set_internal_color (create {EV_COLOR}.make_with_8_bit_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					set_internal_color (default_highlight_color)
				end
			end
		end

feature -- Constants

	default_color: EV_COLOR
			-- Default color
		deferred
		end

	default_highlight_color: EV_COLOR
			-- Default highlight color
		deferred
		end

end
