indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_ROAD_VIEW

inherit

	TRAFFIC_2D_VIEW [TRAFFIC_ROAD]
		undefine
			default_create,
			out,
			set_x_y,
			is_equal,
			copy,
			publish_mouse_event
		end

	EM_POLYLINE
		rename
			make as make_polyline,
			item as i_th_point
		end

create
	make

feature -- Initialization

	make (a_item: like item) is
			-- Set `item' to `a_item'.
		local
			l: ARRAYED_LIST [EM_VECTOR_2D]
		do
			item := a_item
			from
				create l.make (item.one_way.polypoints.count)
				item.one_way.polypoints.start
			until
				item.one_way.polypoints.off
			loop
				l.extend (create {EM_VECTOR_2D}.make (item.one_way.polypoints.item_for_iteration.x, item.one_way.polypoints.item_for_iteration.y))
				item.one_way.polypoints.forth
			end
			make_from_list (l)
			set_line_color (Default_color)
			set_line_width (7)
			is_highlighted := False
		end

feature -- Element change

	set_color (a_color: TRAFFIC_COLOR) is
			-- Set `color' to `a_color'. May also be Void.
			-- TODO: Does not work yet.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
				else
					set_line_color (default_color)
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR) is
			-- Set `highlight_color' to `a_color'. May also be Void.
			-- TODO: Does not work yet.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
				else
					set_line_color (default_highlight_color)
				end
			end
		end

	highlight is
			-- Highlight the renderable.
		do
			is_highlighted := True
			if highlight_color /= Void then
				set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
			else
				set_line_color (default_highlight_color)
			end
		end

	unhighlight is
			-- Unighlight the renderable.
		do
			is_highlighted := False
			if color /= Void then
				set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
			else
				set_line_color (default_color)
			end
		end

feature -- Constants

	Default_color: EM_COLOR is
			-- Default color
		once
			create Result.make_with_rgb (100, 100, 100)
		end

	Default_highlight_color: EM_COLOR is
			-- Default highlight color
		once
			create Result.make_with_rgb (255, 0, 0)
		end

end
