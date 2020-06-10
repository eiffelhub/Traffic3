note
	description: "Deferred class for vehicles serving a line and pursuing a schedule."
	date: "$Date: 2006/06/06 12:23:40$"
	revision: "$Revision$"

deferred class
	TRAFFIC_LINE_VEHICLE

inherit

	TRAFFIC_VEHICLE

feature -- Element change

	set_line (a_line: TRAFFIC_LINE)
			-- Set `line' to `a_line' and initialize position, etc.
		require
			a_line_exists: a_line /= Void
		do
			line := a_line

			create line_cursor.make (a_line)
			line_cursor.start
			create poly_cursor.make (line_cursor.item_for_iteration.polypoints)
			poly_cursor.start
			move_next
			update_angle
		ensure
			line_set: line = a_line
		end

	set_to_station (a_station: TRAFFIC_STATION)
			-- Set the line vehicle to `a_station'.
		require
			a_station_not_void: a_station /= Void
			-- todo has_station_in_line: line.has_station (a_station)
		local
			found: BOOLEAN
		do
			if a_station = line.terminal_2 then
				line_cursor.set_cursor_direction (False)
				line_cursor.start
				create poly_cursor.make (line_cursor.item_for_iteration.polypoints)
				poly_cursor.start

				move_next
				update_angle
			else
				from
					line_cursor.start
				until
					line_cursor.after or found
				loop
					if line_cursor.item_for_iteration.origin = a_station then
						create poly_cursor.make (line_cursor.item_for_iteration.polypoints)
						poly_cursor.start

						move_next
						update_angle
						found := True
					else
						line_cursor.forth
					end
				end
			end
		end

feature --Access

	line: TRAFFIC_LINE
			-- Line on which `Current' moves

	next_station: TRAFFIC_STATION
			-- Next station the line vehicle stops at

	last_update: INTEGER
			-- Last second the position was updated

feature -- Status report

	is_valid_line (a_line: TRAFFIC_LINE): BOOLEAN
			-- Is `a_line' a valid line for `Current'?
		require
			a_line_exists: a_line /= Void
		deferred
		end


feature -- Basic operations


feature{NONE} --Implementation		

	move_next
			-- Set the positions to the corresponding ones of the line segments.
		do
			origin :=  poly_cursor.item
			location := poly_cursor.item

			-- Do not distinguish between traveling_back and traveling_forward
			poly_cursor.forth
			if poly_cursor.after then
				if not line_cursor.after  then
					-- Set line cursor correctly
					line_cursor.forth
				end
				if line_cursor.after then
					if is_reiterating and line_cursor.line.segment_count >= 1 then
						line_cursor.set_cursor_direction (not line_cursor.is_cursor_one_direction)
						line_cursor.start
						create poly_cursor.make (line_cursor.item_for_iteration.polypoints)
						poly_cursor.start
						destination := poly_cursor.item
					else
						has_finished := True
					end
				else
					create poly_cursor.make (line_cursor.item_for_iteration.polypoints)
					poly_cursor.start
					destination := poly_cursor.item
				end
			else
				destination := poly_cursor.item
			end

		end

	line_cursor: TRAFFIC_LINE_CURSOR
			-- Line segment on which the line vehicle is moving currently

invariant

	line_set: line /= void
	line_cursor_exists: line_cursor /= Void

end
