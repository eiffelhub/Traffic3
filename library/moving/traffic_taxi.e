note
	description: "Class for taxis working for a taxi office"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_TAXI

inherit

	TRAFFIC_VEHICLE
		redefine
			advance
		end



create
	make_random

feature {NONE} -- Initialization

	make_random (a_point_list: DS_ARRAYED_LIST [TRAFFIC_POINT])
			-- Create a taxi with an associated 'a_taxi_office'.
			-- Random speed and stops at 'stops' random positions.
			-- Set seed of random_number to 'a_seed'.
		require
			valid_number_of_stops: a_point_list /= Void and then a_point_list.count >= 2
		do
			create polypoints.make_from_linear (a_point_list)
			create poly_cursor.make (polypoints)
			poly_cursor.start

			set_reiterate (true)
			move_next
			update_angle

			unit_capacity := 4
			speed := 17
			start
			create changed_event

		ensure
			polypoints_not_empty: polypoints /= Void and then polypoints.count >= a_point_list.count
		end

feature -- Access

	count: INTEGER
			-- Current amount of load

	color: TRAFFIC_COLOR
			-- Color of the taxi office
		once
			create Result.make_with_rgb (255, 0, 0)
		end

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
		do
			Result := True
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
		do
			Result := True
		end

	busy: BOOLEAN
			--Is taxi busy?

feature -- Basic operations

	load(a_quantity: INTEGER)
			-- Load cargo or a passenger.
    	do
			count := count + a_quantity
    	end

    unload(a_quantity: INTEGER)
			-- Load cargo or a passenger.
    	do
			count := count - a_quantity
    	end

	take (from_location: TRAFFIC_POINT; to_location: TRAFFIC_POINT)
			-- If not `busy', take a request. Pick somebody up at from_location and bring him or her to to_location.
		require
			locations_exist: from_location /= Void and to_location /= Void
			close_to_taxi: from_location.distance (location) <= 100.0
		do
			if not busy then
				-- Set taxi busy and take it out of the available_taxi_list of the office.
				set_request_information (from_location, to_location)
				busy := True
				-- Set is_marked to true so that the view will draw the busy taxi marked.
				is_marked := True
				update_angle
				changed_event.publish ([])
			end
		end


feature{NONE} --Implementation

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

	advance
			-- Take a tour in the city.
			-- Set new random directions and if 'Current' has done a request and is available again.
		do
			Precursor
			if has_finished and busy then
					-- Taxi has fullfilled a request.
					-- Add new random directions.
					-- Set new destination
					origin := location
					destination := polypoints.first
					has_finished := false
					set_reiterate (true)
					-- Taxi is available again.
					busy := false
					is_marked := false
			end
		end

	polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT]

	set_request_information (from_location: TRAFFIC_POINT; to_location: TRAFFIC_POINT)
			-- Set new origin and destination, new points to drive from from_location to to_location.
		require
			valid_from_location: from_location /= void
			valid_to_locaton: to_location /= void
		local
			new_polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			-- New polypoint to travel through.
			create new_polypoints.make(0)
			-- Wait so that passenger can board.
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			new_polypoints.force_last(from_location)
			-- Wait so that passenger can deboard.
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			new_polypoints.force_last(to_location)
			polypoints := new_polypoints
			polypoints.start
			-- Set the new origin and destination.
			origin := location
			destination := from_location
			set_reiterate (false)
		end

invariant
	legal_limit: capacity = 4
end
