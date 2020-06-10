note
	description: "View for transportation lines"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_LINE_VIEW

inherit

	TRAFFIC_VS_VIEW [TRAFFIC_LINE]
		undefine
			hide,
			show,
			copy,
			is_equal,
			draw
		redefine
			unhighlight,
			highlight,
			set_color,
			set_highlight_color
		end

	DRAWABLE_OBJECT_CONTAINER [TRAFFIC_LINE_SEGMENT_VIEW]
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

	make (a_item: like item) 
			-- Initialize view for `a_item'.
		local
			c: TRAFFIC_LINE_SEGMENT_VIEW
			lc: TRAFFIC_LINE_CURSOR
		do
			make_container
			item := a_item
			from
				create lc.make (item)
				lc.start
			until
				lc.after
			loop
				create c.make (lc.item_for_iteration)
				put_last (c)
				lc.forth
			end
			if item.color /= Void  then
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (item.color)
					forth
				end
			else
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_color.red_8_bit, default_color.green_8_bit, default_color.blue_8_bit))
					forth
				end
			end
			is_shown := True
			is_highlighted := False
			item.changed_event.subscribe (agent update)
			item.element_inserted_event.subscribe (agent add_connection_view (?))
			item.element_removed_event.subscribe (agent remove_connection_view (?))
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
			create Result.make_with_8_bit_rgb (255, 0, 0)
		end

feature -- Basic operations

	update
			-- Update the view to represent changes in the city item.
		do
			from
				start
			until
				after
			loop
				item_for_iteration.update
				forth
			end
		end

	highlight
			-- Highlight the view.
		do
			if highlight_color /= Void then
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (highlight_color)
					forth
				end
			else
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_highlight_color.red_8_bit, default_highlight_color.green_8_bit, default_highlight_color.blue_8_bit))
					forth
				end
			end
			is_highlighted := True
		end

	unhighlight
			-- Unhighlight the view.
		do
			if color /= Void then
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (color)
					forth
				end
			else
				from
					start
				until
					after
				loop
					item_for_iteration.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_color.red_8_bit, default_color.green_8_bit, default_color.blue_8_bit))
					forth
				end
			end
			is_highlighted := False
		end

	set_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			color := a_color
			if not is_highlighted then
				if color /= Void then
					from
						start
					until
						after
					loop
						item_for_iteration.set_color (color)
						forth
					end
				else
					from
						start
					until
						after
					loop
						item_for_iteration.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_color.red_8_bit, default_color.green_8_bit, default_color.blue_8_bit))
						forth
					end
				end
			end
		end

	set_highlight_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		do
			highlight_color := a_color
			if is_highlighted then
				if highlight_color /= Void then
					from
						start
					until
						after
					loop
						item_for_iteration.set_color (highlight_color)
						forth
					end
				else
					from
						start
					until
						after
					loop
						item_for_iteration.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_highlight_color.red_8_bit, default_highlight_color.green_8_bit, default_highlight_color.blue_8_bit))
						forth
					end
				end
			end
		end

feature {NONE} -- Implementation

	add_connection_view (a_item: TRAFFIC_LINE_SEGMENT)
			-- Add new view for inserted item.
		local
			c: TRAFFIC_LINE_SEGMENT_VIEW
		do
			create c.make (a_item)
			put_last (c)
			if item.color /= Void  then
				c.set_color (item.color)
			else
				c.set_color (create {TRAFFIC_COLOR}.make_with_rgb (default_color.red_8_bit, default_color.green_8_bit, default_color.blue_8_bit))
			end
		end

	remove_connection_view (a_item: TRAFFIC_LINE_SEGMENT)
			-- Add new view for inserted item.
		local
			found: BOOLEAN
		do
			from
				start
			until
				after or found
			loop
				if item_for_iteration.item.is_equal (a_item) then
					found := True
					delete (item_for_iteration)
				else
					forth
				end
			end
		end

	new_connection_view (a_item: TRAFFIC_SEGMENT): DRAWABLE_POLYLINE
			-- Generate connection view for `a_item'.
		local
			pp: ARRAY [REAL_COORDINATE]
			i: INTEGER
		do
			create pp.make (1, a_item.polypoints.count)
			from
				i := 1
			until
				i > a_item.polypoints.count
			loop
				pp.put (create {REAL_COORDINATE}.make (a_item.polypoints.item (i).x, -a_item.polypoints.item (i).y), i)
				i := i + 1
			end
			create Result.make (pp, 634.0)
		ensure
			Result_exists: Result /= Void
		end

end
