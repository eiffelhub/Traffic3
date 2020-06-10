note
	description: "Public transportation line where objects of a given type move along."
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"

class
	TRAFFIC_LINE

inherit

	HASHABLE
		redefine
		 	out
		select
			out,
			copy,
			is_equal
		end

	TRAFFIC_EVENT_CONTAINER [TRAFFIC_LINE_SEGMENT]
		undefine
			out
		end

	DOUBLE_MATH
		rename copy as math_copy,
				is_equal as math_equal,
				out as math_out
		end

	TRAFFIC_CITY_ITEM
		undefine
			is_equal,
			copy,
			out
		redefine
			highlight,
			unhighlight,
			add_to_city,
			remove_from_city
		end
create
	make, make_with_terminal, make_metro

feature {NONE} -- Initialization

	make (a_name: STRING; a_type: TRAFFIC_TYPE_LINE)
			-- Create a line with name `a_name' of type `a_type'.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			a_type_exists: a_type /= Void
		local
			temp_type: TRAFFIC_TYPE_LINE
		do
			name := a_name
			temp_type ?= a_type
			if a_type/=Void then
				type:= temp_type
			end
			create one_direction.make
			create other_direction.make
			create stops.make

			create changed_event
			create element_inserted_event
			create element_removed_event
			index := 1
		ensure
			name_set: equal (name, a_name)
			has_type_set: type /=Void -- have to be same object
			type_set: type=a_type
			count_line_segment_not_void: segment_count >= 0 -- List is initilalized.
			element_inserted_event_exists: element_inserted_event /= Void
			element_removed_event_exists: element_removed_event /= Void
			one_direction_exists: one_direction /= Void
			other_direction_exists: other_direction /= Void
		end

	make_metro (a_name: STRING)
			-- Create a line with name `a_name' of type TRAFFIC_TYPE_TRAM.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			name := a_name
			type:= create {TRAFFIC_TYPE_TRAM}.make
			create one_direction.make
			create other_direction.make
			create stops.make

			create changed_event
			create element_inserted_event
			create element_removed_event
			index := 1
		ensure
			name_set: equal (name, a_name)
			has_type_set: type /=Void
			count_line_segment_not_void: segment_count >= 0 -- List is initilalized.
			element_inserted_event_exists: element_inserted_event /= Void
			element_removed_event_exists: element_removed_event /= Void
			one_direction_exists: one_direction /= Void
			other_direction_exists: other_direction /= Void
		end


	make_with_terminal (a_name: STRING; a_type: TRAFFIC_TYPE_LINE; a_station: TRAFFIC_STATION)
			-- Create a line with a name `a_name' of type `a_type' and a planned terminal `a_station'.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			a_type_exists: a_type /= Void
			a_station_exists: a_station /= Void
		local
			s: TRAFFIC_STOP
		do
			make (a_name, a_type)
			if a_station.has_stop (current) then
				stops.extend (a_station.stop (current))
			else
				create s.make_with_location (a_station, Current, create {TRAFFIC_POINT}.make_from_other (a_station.location))
				stops.extend (s)
			end
		ensure
			name_set: equal (name, a_name)
			has_type_set: type /=Void -- have to be same object
			type_set: type=a_type
			count_line_segment_not_void: segment_count >= 0 -- List is initilalized.
			element_inserted_event_exists: element_inserted_event /= Void
			element_removed_event_exists: element_removed_event /= Void
			one_direction_exists: one_direction /= Void
			other_direction_exists: other_direction /= Void
		end

feature -- Measurement

	total_time: REAL_64
			-- Estimated travel time for full line, time measured in Minutes.
			-- By Speed which depends on the type of the line
		do
			from
				stops.start
				Result:=0.0
			invariant
				-- The value of Result is the time to travel from first station
				-- to station at cursor position
			variant
				stops.count-stops.index
			until
				stops.islast
			loop
				Result := Result + stops.item.time_to_next
				stops.forth
			end
		end


	segment_count: INTEGER
			-- Number of segments per direction in line
		do
			Result := one_direction.count
		end

	count: INTEGER
			-- Number of stations in this line
		do
			Result := stops.count
		end

feature -- Access

	index: INTEGER
			-- Internal cursor index

	i_th (i: INTEGER): TRAFFIC_STATION
			-- The i-th station on this line		
		require
			not_too_small: i >= 1
			not_too_big: i <= count
		do
			if not is_empty then
				Result := stops.i_th (i).station
			end
		end

	item: TRAFFIC_STATION
			-- Item at internal cursor position of line
		require
			not_after: not after
		do
			Result := i_th (index)
		end

	hash_code: INTEGER
			-- Hash code value
		do
			Result := (name + type.name).hash_code
		end

	name: STRING
			-- Name of line

	type: TRAFFIC_TYPE_LINE
			-- Type of line

	terminal_1: TRAFFIC_STATION
			-- Terminal of line in one direction
		do
			if not is_empty then
				result := stops.first.station
			end
		end

	terminal_2: TRAFFIC_STATION
			-- Terminal of line in other direction
		do
			if not is_empty then
				result := stops.last.station
			end
		end

	color: TRAFFIC_COLOR
			-- Line color
			-- Used as color represenation

	south_end: TRAFFIC_STATION
			-- End station on South side
			do
				if not is_empty then
					Result := stops.first.station
				end
			end

	north_end: TRAFFIC_STATION
			-- End station on North side
			do
				if not is_empty then
					Result := stops.last.station
				end
			end

	stops: LINKED_LIST[TRAFFIC_STOP]
			-- A list of all stops of this line


	road_points: DS_ARRAYED_LIST[TRAFFIC_POINT]
			-- Polypoints from the roads belonging to this line
		local
			roads:ARRAYED_LIST[TRAFFIC_ROAD_SEGMENT]
			pp: DS_ARRAYED_LIST[TRAFFIC_POINT]
			invert, is_station: BOOLEAN
			v: TRAFFIC_POINT
			lc: TRAFFIC_LINE_CURSOR
		do
			create Result.make(1)
			-- loop on all the line segments
			from
				create lc.make (Current)
				lc.start
			until
				lc.after
			loop
				roads:=lc.item_for_iteration.roads
				is_station:=true
				-- loop on all the roads

				if lc.item_for_iteration.origin=roads.first.origin and lc.item_for_iteration.destination=roads.last.destination then
					invert:=false
				elseif lc.item_for_iteration.origin=roads.last.destination and lc.item_for_iteration.destination=roads.first.origin then

					invert:=true
				else
					io.putstring ("Invalid roads for given line segment%N")
					io.putstring("Line segment origin: "+lc.item_for_iteration.origin.name+" - Line segment destination:"+lc.item_for_iteration.destination.name+"%N")
				end
				if invert then
					from
						roads.finish
					until
						roads.before
					loop
						pp:=roads.item.polypoints
						-- loop on all the polypoints
						from
							pp.finish
						until
							pp.before
						loop
							v:=pp.item_for_iteration
							Result.force_last (v)
							pp.back
						end

						roads.back
					end
				else
					from
						roads.start
					until
						roads.after
					loop
						pp:=roads.item.polypoints
						-- loop on all the polypoints
						from
							pp.start
						until
							pp.after
						loop
							v:=pp.item_for_iteration
							Result.force_last (v)
							pp.forth
						end

						roads.forth
					end
				end

				forth
			end
		end

	is_forward(a_start,a_destination: TRAFFIC_STATION): BOOLEAN
			-- do you have to move forward to get from a to b?
		require
			on_this_line: a_start.lines.has (current) and a_destination.lines.has (current)
		local
			one_dir: DS_LINKED_LIST [TRAFFIC_LINE_SEGMENT]
			found: BOOLEAN
		do
			from
				found := false
				one_dir := one_direction.twin -- don't change the internal cursor position
				one_dir.start
			until
				found
			loop
				if one_dir.item_for_iteration.origin = a_start then
					found := true
					result := true
				elseif one_dir.item_for_iteration.origin = a_destination then
					found := true
					result := false
				end
				one_dir.forth
			end
		end

	get_segments(a_origin, a_destination: TRAFFIC_STATION): LINKED_LIST[TRAFFIC_LINE_SEGMENT]
			-- Line segments connecting `a_origin' and `a_destination'
		require
			on_this_line: a_origin.lines.has (current) and a_destination.lines.has (current)
			not_same: a_origin /= a_destination
		local
			segments: DS_LINKED_LIST [TRAFFIC_LINE_SEGMENT]
			start_found, done: BOOLEAN
		do
			create Result.make

			if is_forward(a_origin, a_destination) then
				segments := one_direction
			else
				segments := other_direction
			end

			from
				segments.start
				start_found := false
			until
				done
			loop
				if start_found then
					Result.extend(segments.item_for_iteration)
				end
				if segments.item_for_iteration.origin = a_origin then
					Result.extend(segments.item_for_iteration)
					start_found := true
				end
				if segments.item_for_iteration.destination = a_destination then
					done := true
				end
				segments.forth
			end
		end



feature -- Cursor movement

	start
			-- Bring station cursor to frist element.
		do
			index := 1
		ensure
			on_first: index = 1
		end

	forth
			-- Move internal cursor to next position.
		require
			not_after: not after
		do
			index := index + 1
		ensure
			moved_forth: index = old index + 1
		end

	go_i_th (i: INTEGER)
			-- Move station cursor to item at position i
		require
			not_over_left:  i >= 0
			not_over_right: i <= count+1
		do
			index := i
		ensure
			set: index = i
		end



feature -- Status report





	has (v: TRAFFIC_LINE_SEGMENT): BOOLEAN
			-- Does list include `v'?
		do
			Result := one_direction.has (v) or other_direction.has (v)
		ensure
			not_empty: Result implies not is_empty
		end

	is_empty: BOOLEAN
			-- Does `current' have any stops?
		do
			Result := stops.is_empty
		end

	after: BOOLEAN
			-- Is there no valid position to right of internal cursor?
		do
			Result := index > count
		end

	is_before: BOOLEAN
			-- Is there no valid position to left of internal cursor?
		do
			Result := index = 0
		end

feature -- Element change

	highlight
			-- Highlight all line segments
		local
			lc: TRAFFIC_LINE_CURSOR
		do
			is_highlighted := True
			create lc.make (Current)
			from
				lc.start
			until
				lc.after
			loop
				lc.item_for_iteration.highlight
				lc.forth
			end
			from
				lc.start
				lc.set_cursor_direction (False)
			until
				lc.after
			loop
				lc.item_for_iteration.highlight
				lc.forth
			end
			changed_event.publish ([])
		end

	unhighlight
			-- Unhighlight all line segments
		local
			lc: TRAFFIC_LINE_CURSOR
		do
			is_highlighted := False
			create lc.make (Current)
			from
				lc.start
			until
				lc.after
			loop
				lc.item_for_iteration.unhighlight
				lc.forth
			end
			from
				lc.start
				lc.set_cursor_direction (False)
			until
				lc.after
			loop
				lc.item_for_iteration.unhighlight
				lc.forth
			end
			changed_event.publish ([])
		end

	set_color (a_color: TRAFFIC_COLOR)
			-- Set color to `a_color'.
		require
			a_color_exists: a_color /= Void
		do
			color := a_color
			changed_event.publish ([])
		ensure
			color_set: color = a_color
		end

feature {TRAFFIC_ITEM_LINKED_LIST} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all nodes to `a_city'.
		local
			lc: TRAFFIC_LINE_CURSOR
		do
			is_in_city := True
			city := a_city
			from
				create lc.make (Current)
				lc.start
				lc.set_cursor_direction (True)
			until
				lc.after
			loop
				lc.item_for_iteration.add_to_city (city)
				lc.forth
			end
			from
				lc.start
				lc.set_cursor_direction (False)
			until
				lc.after
			loop
				lc.item_for_iteration.add_to_city (city)
				lc.forth
			end
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			wipe_out
			is_in_city := False
			city := Void
		end

feature -- Removal

	remove_all_segments, wipe_out
			-- Remove all segments.
		local
			first_stop: TRAFFIC_STOP
		do
			from
				one_direction.start
			until
				one_direction.off
			loop
				element_removed_event.publish ([one_direction.item_for_iteration])
				one_direction.item_for_iteration.remove_from_city
				one_direction.forth
			end
			one_direction.wipe_out
			from
				other_direction.start
			until
				other_direction.off
			loop
				other_direction.item_for_iteration.remove_from_city
				element_removed_event.publish ([other_direction.item_for_iteration])
				other_direction.forth
			end
			other_direction.wipe_out

			-- keep first stop
			if not is_empty then
				first_stop := stops.first
				stops.wipe_out
				stops.extend (first_stop)
			end
		ensure
			only_one_left: count = 1
			both_ends_same: south_end = north_end
		end


	remove_color
			-- Remove color.
		do
			color := Void
			changed_event.publish ([])
		ensure
			color_removed: color = Void
		end

	remove_last
			-- Remove end of the line.
		require
			count_valid: segment_count >= 1
		do
			element_removed_event.publish ([one_direction.last])
			if one_direction.last.is_in_city then
				one_direction.last.remove_from_city
			end
			one_direction.remove_last
			element_removed_event.publish ([other_direction.first])
			if other_direction.first.is_in_city then
				other_direction.first.remove_from_city
			end
			other_direction.remove_first
			-- remove last stop
			stops.go_i_th (stops.count)
			stops.remove
		ensure
			count_smaller: segment_count = old segment_count - 1
		end

	remove_first
			-- Remove start of the line.
		require
			count_valid: segment_count >= 1
		do
			element_removed_event.publish ([one_direction.first])
			element_removed_event.publish ([other_direction.last])
			if one_direction.first.is_in_city then
				one_direction.first.remove_from_city
			end
			if other_direction.last.is_in_city then
				other_direction.last.remove_from_city
			end
			one_direction.remove_first
			other_direction.remove_last
			-- remove first stop
			stops.start
			stops.remove
		ensure
			count_smaller: segment_count = old segment_count - 1
		end

feature -- Status report


	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- E.g. are all needed elements already inserted in the city?
		local
			lc: TRAFFIC_LINE_CURSOR
		do
			Result := True
			from
				create lc.make (Current)
				lc.start
			until
				lc.after or not Result
			loop
				if lc.item_for_iteration.start_node.is_in_city and lc.item_for_iteration.end_node.is_in_city and
						lc.item_for_iteration.origin.is_in_city and lc.item_for_iteration.destination.is_in_city then
					Result := True
				else
					Result := False
				end
				lc.forth
			end
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
		do
			Result := True
		end

	is_terminal (a_terminal: TRAFFIC_STATION): BOOLEAN
			-- Is `a_terminal' a terminal of line?
		require
			a_terminal_exists: a_terminal /= Void
		do
			Result := equal (a_terminal, terminal_1) or equal (a_terminal, terminal_2)
		end

feature -- Basic operations

	put_first (l1, l2: TRAFFIC_LINE_SEGMENT)
			-- Add l1 and l2 at beginning (l2 connects the same two stations in reverse order).
		require
			l1_exists: l1 /= Void
			l2_exists: l2 /= Void
			l1_fits: terminal_1 /= Void implies l1.destination = terminal_1
			l2_fits: terminal_1 /= Void implies l2.origin = terminal_1
			l1_fits_l2: l1.start_node = l2.end_node and l1.end_node = l2.start_node
		do
			one_direction.put_first (l1)
			other_direction.put_last (l2)
			-- add stops at beginning of list
			if is_empty then
				stops.extend (l1.end_node)
			end
			stops.put_front(l1.start_node)
			l1.set_line (Current)
			l2.set_line (Current)
			if is_in_city then
				l1.add_to_city (city)
				l2.add_to_city (city)
			end
			element_inserted_event.publish ([l1])
			element_inserted_event.publish ([l2])
		end

	put_last (l1, l2: TRAFFIC_LINE_SEGMENT)
			-- Add l1 and l2 at end (l2 connects the same two stations in reverse order).
		require
			l1_exists: l1 /= Void
			l2_exists: l2 /= Void
			l1_fits: terminal_2 /= Void implies l1.origin = terminal_2
			l2_fits: terminal_2 /= Void implies l2.destination = terminal_2
			l1_fits_l2: l1.start_node = l2.end_node and l1.end_node = l2.start_node
		do
			one_direction.put_last (l1)
			other_direction.put_first (l2)

			--add stops at end of list
			if is_empty then
				stops.extend (l1.start_node)
			end
			stops.extend (l1.end_node)
			l1.set_line (Current)
			l2.set_line (Current)
			if is_in_city then
				l1.add_to_city (city)
				l2.add_to_city (city)
			end
			element_inserted_event.publish ([l1])
			element_inserted_event.publish ([l2])
		end

	extend (s: TRAFFIC_STATION)
			-- Add connection (segment) to `a_station' at end.
		require
			not_empty: not is_empty
		local
			l1, l2: TRAFFIC_LINE_SEGMENT
			s1, s2: TRAFFIC_STOP
			pp: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			s1 := terminal_2.stop (current)
			if s.has_stop (Current) then
				s2 := s.stop (Current)
			else
				create s2.make_with_location (s, Current, create {TRAFFIC_POINT}.make_from_other (s.location))
			end
			create pp.make (2)
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s1.location))
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s2.location))
			create l1.make (s1, s2, type, pp)
			create pp.make (2)
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s2.location))
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s1.location))
			create l2.make (s2, s1, type, pp)

			put_last (l1, l2)
		ensure
			new_station_added: i_th (count) = s
			added_at_NE: north_end = s
			one_more: count = old count + 1
		end

	prepend (a_station: TRAFFIC_STATION)
			-- Add connection (segment) from `a_station' to the beginning of the line.
		require
			has_terminal_1: terminal_1 /= void
			not_emtpy: not is_empty
		local
			l1, l2: TRAFFIC_LINE_SEGMENT
			s1, s2: TRAFFIC_STOP
			pp: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			if a_station.has_stop (Current) then
				s1 := a_station.stop (Current)
			else
				create s1.make_with_location (a_station, Current, create {TRAFFIC_POINT}.make_from_other (a_station.location))
			end
			s2  := stops.first
			create pp.make (2)
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s1.location))
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s2.location))
			create l1.make (s1, s2, type, pp)
			create pp.make (2)
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s2.location))
			pp.force_last (create {TRAFFIC_POINT}.make_from_other (s1.location))
			create l2.make (s2, s1, type, pp)

			put_first (l1, l2)
		ensure
			new_station_added: i_th (1) = a_station
			added_at_end: terminal_1 = a_station
			one_more: count = old count + 1
		end


feature -- Output

	out: STRING
			-- Textual representation
		local
			color_text: STRING
			c: TRAFFIC_LINE_CURSOR
		do
			if color /= Void then
				color_text := color.out
			else
				color_text := ""
			end
			Result := "Traffic " + type.out + " line: " + name + ", " + color_text +
				"%N  one direction"
			from
				create c.make (Current)
				c.start
			until
				c.after
			loop
				Result := Result + "%T" + c.item_for_iteration.out + "%N"
				c.forth
			end
			Result := Result + "%N  one direction"
			from
				c.set_cursor_direction (False)
				c.start
			until
				c.after
			loop
				Result := Result + "%T" + c.item_for_iteration.out + "%N"
				c.forth
			end
		end

feature {TRAFFIC_LINE_CURSOR} -- Implementation

	one_direction, other_direction: DS_LINKED_LIST [TRAFFIC_LINE_SEGMENT]

	angle(st,dest: TRAFFIC_POINT):REAL_64
			-- Set the angles to the x- and y-axis respectively.
		local
			x_difference, y_difference, hypo, quad: REAL_64
			angle_x:REAL_64
		do
			x_difference := st.x - dest.x
			y_difference := st.y - dest.y
			hypo := sqrt ((x_difference * x_difference) + (y_difference * y_difference))

			if hypo /= 0 then
				-- arc_sine in radian
				quad := 0
				if  (x_difference >= 0) and (y_difference >= 0) then
					angle_x := arc_sine (x_difference/hypo)
						-- the same in degree
					angle_x := angle_x * 180 / pi
					angle_x := 180 + angle_x
				elseif (x_difference < 0) and (y_difference >= 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
						-- the same in degree
					angle_x := angle_x * 180 / pi
					angle_x := 180 - angle_x
				elseif (x_difference < 0) and (y_difference < 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
						-- the same in degree
					angle_x := angle_x * 180 / pi
				elseif (x_difference >= 0) and (y_difference < 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
						-- the same in degree
					angle_x := angle_x * 180 / pi
					angle_x := 360 - angle_x
				end

				if angle_x < 0 then
					angle_x := 360 + angle_x
				elseif angle_x > 360 then
					angle_x := angle_x - 360
				end
			end
			if angle_x>180 then
				Result:=angle_x-180
			else
				Result:=angle_x
			end
		end

invariant

	southwest_is_first: south_end = i_th (1)
	northeast_is_last: north_end = i_th (count)
	name_not_void: name /= Void -- Line has name.
	name_not_empty: not name.is_empty -- Line has not empty name.
	segments_not_void: one_direction /= Void and other_direction /= Void
	stops_not_void: stops /= void
	one_more_stop: (count = 0 and segment_count = 0) or (count = segment_count +1)
	type_exists: type /= Void -- Line has type.
	counts_are_equal: one_direction.count = other_direction.count
	after: after = (index = count + 1)
end
