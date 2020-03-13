indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_LINE_VIEW

inherit

	TRAFFIC_2D_VIEW [TRAFFIC_LINE]
		undefine
			default_create,
			out,
			set_x_y,
			is_equal,
			copy,
			publish_mouse_event,
			initialize_events
		end

	EM_DRAWABLE_CONTAINER [EM_POLYLINE]
		rename
			item as i_th_drawable,
			make as make_container
		end

create
	make

feature -- Initialization

	make (a_item: like item) is
			-- Set `item' to `a_item'.
		do
			item := a_item
			make_container
			from
				item.start
			until
				item.off
			loop
				extend (new_connection_drawable (item.item_for_iteration))
				item.forth
			end
			set_color (item.color)
			is_highlighted := False
		end

feature -- Element change

	set_color (a_color: TRAFFIC_COLOR) is
			-- Set `color' to `a_color'. May also be Void.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					from
						start
					until
						off
					loop
						item_for_iteration.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
						forth
					end
				else
					from
						start
					until
						off
					loop
						item_for_iteration.set_line_color (default_color)
						forth
					end
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR) is
			-- Set `highlight_color' to `a_color'. May also be Void.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					from
						start
					until
						off
					loop
						item_for_iteration.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
						forth
					end
				else
					from
						start
					until
						off
					loop
						item_for_iteration.set_line_color (default_highlight_color)
						forth
					end
				end
			end
		end

	highlight is
			-- Highlight the renderable.
		do
			is_highlighted := True
			if highlight_color /= Void then
				from
					start
				until
					off
				loop
					item_for_iteration.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					forth
				end
			else
				from
					start
				until
					off
				loop
					item_for_iteration.set_line_color (default_highlight_color)
					forth
				end
			end
		end

	unhighlight is
			-- Unighlight the renderable.
		do
			is_highlighted := False
			if color /= Void then
				from
					start
				until
					off
				loop
					item_for_iteration.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
					forth
				end
			else
				from
					start
				until
					off
				loop
					item_for_iteration.set_line_color (default_color)
					forth
				end
			end
		end

feature -- Constants

	Default_color: EM_COLOR is
			-- Default color
		once
			create Result.make_with_rgb (0, 0, 0)
		end

	Default_highlight_color: EM_COLOR is
			-- Default highlight color
		once
			create Result.make_with_rgb (255, 0, 0)
		end

feature {NONE} -- Implementation

	new_connection_drawable (a_connection: TRAFFIC_LINE_CONNECTION): EM_POLYLINE is
			--
		local
			l: ARRAYED_LIST [EM_VECTOR_2D]
		do
			from
				create l.make (a_connection.polypoints.count)
				a_connection.polypoints.start
			until
				a_connection.polypoints.off
			loop
				l.extend (create {EM_VECTOR_2D}.make (a_connection.polypoints.item_for_iteration.x, a_connection.polypoints.item_for_iteration.y))
				a_connection.polypoints.forth
			end
			create Result.make_from_list (l)
			Result.set_line_width (5)
		end

end
