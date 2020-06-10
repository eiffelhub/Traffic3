note
	description: "Objects that use a vehicle to travel"
	date: "$Date: 6/6/2006$"
	revision: "$Revision$"

class
	TRAFFIC_PASSENGER

inherit
		TRAFFIC_MOVING
			rename
				start as go
			end

create
	make_with_route

feature -- Initialization

	make_with_route (a_route: TRAFFIC_ROUTE; a_speed: REAL_64)
			-- Set passenger's route to be `a_route' and `speed' to `a_speed' (in m/s).
		require
			a_route_not_void: a_route /= Void
		local
			list: DS_ARRAYED_LIST [TRAFFIC_POINT]
			conns: DS_LINKED_LIST [TRAFFIC_SEGMENT]
		do
			route := a_route
			location := a_route.origin.location
			conns := a_route.segments
			create list.make (conns.count + 1)
			from
				conns.start
			until
				conns.off
			loop
				list.append_last (conns.item_for_iteration.polypoints)
				conns.forth
			end
			create poly_cursor.make (list)
			poly_cursor.start
			move_next
			update_angle
			speed := a_speed
			create changed_event
		end

feature -- Access

	route: TRAFFIC_ROUTE
			-- Route to take

	intended_line: TRAFFIC_LINE
			-- Line to use next

	current_vehicle: TRAFFIC_VEHICLE
			-- Vehicle passenger is traveling by
			-- Void if passenger uses no means of transportation

	boarding_stop: INTEGER
			-- Stop where passenger intends to board
			-- Number of stops from line start until where to board

	deboarding_stop: INTEGER
			-- Stop where passenger intends to get off
			-- Number of stops from line start until where to get off

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
		do
			Result := True
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `a_city'?
		do
			Result := True
		end

	direction_line_back: BOOLEAN
			-- In which direction to travel?
			-- If the deboarding_stop is less than the boarding_stop the passenger has to use
			-- a vehicle that travels back on its line.

feature {NONE} -- Implementation

	move_next
			--  Move to following position
		do
			-- Set the locations to the corresponding ones of the line segment.
			origin :=  poly_cursor.item
			location := poly_cursor.item
			if is_traveling_back then
				poly_cursor.back
				if poly_cursor.before then
					is_traveling_back := False
					poly_cursor.forth
					move_next
				else
					destination := poly_cursor.item
				end
			elseif is_reiterating then
				poly_cursor.forth
				if poly_cursor.after then
					is_traveling_back := True
					poly_cursor.back
					move_next
				else
					destination := poly_cursor.item
				end
			else
				poly_cursor.forth
				if poly_cursor.after then
					has_finished := True
				else
					destination := poly_cursor.item
				end
			end
		end

	set_intended_line_info (a_line: TRAFFIC_LINE; a_boarding_stop: INTEGER; a_deboarding_stop: INTEGER)
			-- Set where 'Current' intends to board and to get off.
		require
			line_not_empty: a_line /= Void
			valid_stop: a_boarding_stop > 0 and a_boarding_stop <= a_line.segment_count
			valid_stop: a_deboarding_stop > 0 and a_deboarding_stop <= a_line.segment_count
		do
			intended_line := a_line
			boarding_stop := a_boarding_stop
			deboarding_stop := a_deboarding_stop
			if a_deboarding_stop < a_boarding_stop then
					direction_line_back := true
				else
					direction_line_back := false
			end
		ensure
			line_set: intended_line /= Void
			stop_set: boarding_stop > 0
			stop_set: deboarding_stop > 0
		end

	board (a_line_transport: TRAFFIC_LINE_VEHICLE)
			-- Board 'a_line_transportation'.
		require
			inteded_line: a_line_transport.line = intended_line
		do
			current_vehicle := a_line_transport
			current_vehicle.load (1)
		ensure
			vehicle_set: current_vehicle = a_line_transport
		end

	deboard
			-- Deboard current_vehicle.
		require
			current_vehicle /= void
		do
			current_vehicle.unload(1)
			current_vehicle := void
		ensure
			current_transportatoin_not_set: current_vehicle = void
		end

end

