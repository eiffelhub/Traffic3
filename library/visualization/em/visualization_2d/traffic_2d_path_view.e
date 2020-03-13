indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_PATH_VIEW

inherit

	TRAFFIC_2D_VIEW [TRAFFIC_PATH]
		undefine
			default_create,
			out,
			set_x_y,
			is_equal,
			copy,
			publish_mouse_event,
			initialize_events
		end

	EM_DRAWABLE_CONTAINER [EM_DRAWABLE]
		rename
			item as i_th_drawable,
			make as make_container
		end

create
	make

feature -- Initialization

	make (a_item: like item) is
			-- Set `item' to `a_item'.
		local
			conns: DS_LINKED_LIST [TRAFFIC_CONNECTION]
			c: EM_POLYLINE
			p: EM_RECTANGLE
		do
			item := a_item
			make_container
			from
				conns := item.connections
				conns.start
			until
				conns.after
			loop
				c := new_connection_view (conns.item_for_iteration)
				c.set_line_color (default_color)
				extend (c)
				p := new_place_view (conns.item_for_iteration.origin)
				p.set_fill_color (default_color)
				p.set_line_color (default_color)
				extend (p)
				p := new_place_view (conns.item_for_iteration.destination)
				p.set_fill_color (default_color)
				p.set_line_color (default_color)
				extend (p)
				conns.forth
			end
			is_highlighted := False
		end

feature -- Element change

	set_color (a_color: TRAFFIC_COLOR) is
			-- Set `color' to `a_color'. May also be Void.
		local
			l: EM_POLYLINE
			r: EM_RECTANGLE
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					from
						start
					until
						off
					loop
						l ?= item_for_iteration
						r ?= item_for_iteration
						if l /= Void then
							l.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
						elseif r /= Void then
							r.set_fill_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
							r.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
						end
						forth
					end
				else
					from
						start
					until
						off
					loop
						l ?= item_for_iteration
						r ?= item_for_iteration
						if l /= Void then
							l.set_line_color (default_color)
						elseif r /= Void then
							r.set_fill_color (default_color)
							r.set_line_color (default_color)
						end
						forth
					end
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR) is
			-- Set `highlight_color' to `a_color'. May also be Void.
		local
			l: EM_POLYLINE
			r: EM_RECTANGLE
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					from
						start
					until
						off
					loop
						l ?= item_for_iteration
						r ?= item_for_iteration
						if l /= Void then
							l.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
						elseif r /= Void then
							r.set_fill_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
							r.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
						end
						forth
					end
				else
					from
						start
					until
						off
					loop
						l ?= item_for_iteration
						r ?= item_for_iteration
						if l /= Void then
							l.set_line_color (default_highlight_color)
						elseif r /= Void then
							r.set_fill_color (default_highlight_color)
							r.set_line_color (default_highlight_color)
						end
						forth
					end
				end
			end
		end

	highlight is
			-- Highlight the renderable.
		local
			l: EM_POLYLINE
			r: EM_RECTANGLE
		do
			is_highlighted := True
			if highlight_color /= Void then
				from
					start
				until
					off
				loop
					l ?= item_for_iteration
					r ?= item_for_iteration
					if l /= Void then
						l.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					elseif r /= Void then
						r.set_fill_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
						r.set_line_color (create {EM_COLOR}.make_with_rgb (highlight_color.red, highlight_color.green, highlight_color.blue))
					end
					forth
				end
			else
				from
					start
				until
					off
				loop
					l ?= item_for_iteration
					r ?= item_for_iteration
					if l /= Void then
						l.set_line_color (default_highlight_color)
					elseif r /= Void then
						r.set_fill_color (default_highlight_color)
						r.set_line_color (default_highlight_color)
					end
					forth
				end
			end
		end

	unhighlight is
			-- Unighlight the renderable.
		local
			l: EM_POLYLINE
			r: EM_RECTANGLE
		do
			is_highlighted := False
			if color /= Void then
				from
					start
				until
					off
				loop
					l ?= item_for_iteration
					r ?= item_for_iteration
					if l /= Void then
						l.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
					elseif r /= Void then
						r.set_fill_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
						r.set_line_color (create {EM_COLOR}.make_with_rgb (color.red, color.green, color.blue))
					end
					forth
				end
			else
				from
					start
				until
					off
				loop
					l ?= item_for_iteration
					r ?= item_for_iteration
					if l /= Void then
						l.set_line_color (default_color)
					elseif r /= Void then
						r.set_fill_color (default_color)
						r.set_line_color (default_color)
					end
					forth
				end
			end
		end

feature -- Constants

	Default_color: EM_COLOR is
			-- Default color
		once
			create Result.make_with_rgb (255, 0, 0)
		end

	Default_highlight_color: EM_COLOR is
			-- Default highlight color
		once
			create Result.make_with_rgb (0, 0, 255)
		end

feature {NONE} -- Implementation

	new_connection_view (a_connection: TRAFFIC_CONNECTION): EM_POLYLINE is
			-- New drawable for `a_connection'
		require
			a_connection_exists: a_connection /= Void
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
		ensure
			Result_exists: Result /= Void
		end

	new_place_view (a_place: TRAFFIC_PLACE): EM_RECTANGLE is
			-- New drawable for `a_place'
		require
			a_place_exists: a_place /= Void
		do
			create Result.make_from_coordinates  (a_place.position.x - (a_place.width/2).max (5), a_place.position.y - (a_place.breadth/2).max (5),
								  a_place.position.x + (a_place.width/2).max (5), a_place.position.y + (a_place.breadth/2).max (5))
		ensure
			Result_exists: Result /= Void
		end

end
