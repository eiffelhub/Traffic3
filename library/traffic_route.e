note
	description: "Represents a route from one TRAFFIC_STATION to another"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ROUTE

inherit

	ITERATION_CURSOR [TRAFFIC_LEG]
		undefine
			out
		end

	LINEAR[TRAFFIC_LEG]
		rename
		 	do_all as do_at_every_leg
		redefine
		 	out
		end

	TRAFFIC_CITY_ITEM
		rename
			is_highlighted as is_illuminated,
			highlight as illuminate,
			unhighlight as unilluminate,
			default_create as make_empty
		undefine
			is_equal,
			copy,
			out
		redefine
			make_empty
		select
			make_empty
		end

feature -- Initialization

	make_empty 
			-- Initialize `scale_factor'.
		do
			scale_factor := 1
			create changed_event
			after := True
		ensure then
			scale_factor_set: scale_factor = 1
		end

feature -- Access

	count: INTEGER
			-- Number of legs (route_sections)
		local
			l: TRAFFIC_LEG
		do
			from
				l := first
			until
				l = Void
			loop
				l := l.next
				Result := Result + 1
			end
		end

	first: TRAFFIC_LEG
			-- First leg

	last: TRAFFIC_LEG
			-- Last route leg
		do
			if first /= Void then
				from
					result := first
				until
					result.next = void
				loop
					result := result.next
				end
			end
		end


	origin: TRAFFIC_STATION
			-- Origin of the route
		require
			first_exists: first /= Void
		do
			Result := first.origin
		end

	destination: TRAFFIC_STATION
			-- Destination of the route
		require
			first_exists: first /= Void
		do
			Result := segments.last.destination
		end

	segments: DS_LINKED_LIST [TRAFFIC_SEGMENT]
			-- All segments traveled by the route
		require
			first_exists: first /= Void
		local
			ps: TRAFFIC_LEG
		do
			from
				ps := first
				create Result.make
			until
				ps = Void
			loop
				from
					ps.segments.start
				until
					ps.segments.after
				loop
					Result.force_last (ps.segments.item_for_iteration)
					ps.segments.forth
				end
				ps := ps.next
			end
		end

	index: INTEGER
			-- Index of current position
		local
			l_active, l_active_iterator: TRAFFIC_LEG
		do
			if after then
				Result := count + 1
			elseif not is_empty and item /= Void then
				from
					Result := 1
					l_active := item
					l_active_iterator := first
				until
					l_active_iterator = l_active or else l_active_iterator = Void
				loop
					l_active_iterator := l_active_iterator.next
					Result := Result + 1
				end
			end
		end

	item: TRAFFIC_LEG
			-- Item at current position

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

	is_valid_for_insertion (a_connection: TRAFFIC_SEGMENT): BOOLEAN
			-- Is `a_connection' valid for insertion?
		require
			connection_exists: a_connection /= Void
		local
			l: TRAFFIC_LEG
		do
			if first = Void then
				Result := True
			else
				from
					l := first
				until
					l.next = Void
				loop
					l := l.next
				end
				Result := l.destination = a_connection.origin
			end
		end

	is_empty: BOOLEAN
			-- Is there no element?
		do
			Result := count = 0
		end

	after: BOOLEAN
			-- Is there no valid position to the right of current one?

feature -- Output

	out: STRING
			-- Description providing information about the route
		local
			leg: TRAFFIC_LEG
			walking_length: REAL_64
			tram_length: REAL_64
			bus_length: REAL_64
			train_length: REAL_64
			tram_type: STRING
			train_type: STRING
			bus_type: STRING

		do
			create Result.make_empty
			Result.append ("Starting at: " + origin.name + "%N")

			tram_type := (create {TRAFFIC_TYPE_TRAM}.make).name
			train_type := (create {TRAFFIC_TYPE_RAIL}.make).name
			bus_type := (create {TRAFFIC_TYPE_BUS}.make).name

			from
				leg := first
			 until
			 	leg = Void
			 loop
				if leg.has_line then
					Result.append ("Take " + leg.line.type.name + " no. " + leg.line.name + " to " + leg.destination.name + "%N")

					if leg.line.type.name.is_equal (tram_type) then
						tram_length := tram_length + leg.length
					elseif leg.line.type.name.is_equal (train_type) then
						train_length := train_length + leg.length
					elseif leg.line.type.name.is_equal (bus_type) then
						bus_length := bus_length + leg.length
					end
				else
					Result.append ("Walk to " + leg.destination.name + "%N")
					walking_length := walking_length + leg.length
				end

				leg := leg.next
			end

			Result.append ("Arriving at: " + destination.name + "%NTotal:")
			if walking_length > 0 then
				Result.append ("%NWalking: " + (walking_length* scale_factor).rounded.out + " m")
			end
			if tram_length > 0 then
				Result.append ("%NTram: " + (tram_length * scale_factor).rounded.out + " m")
			end
			if bus_length > 0 then
				Result.append ("%NBus: " + (bus_length * scale_factor).rounded.out + " m")
			end
			if train_length > 0 then
				Result.append ("%NTrain: " + (train_length * scale_factor).rounded.out + " m")
			end
		end

feature -- Basic operations


	animate
			-- Create passenger that walks along `Current', add it to city, and make it start walking.
		require
			city_has_route: is_in_city
		local
			passenger: TRAFFIC_PASSENGER
		do
			create passenger.make_with_route (Current, 5.0)
			city.passengers.put_last (passenger)
			passenger.go
		end


	extend(a_leg: TRAFFIC_LEG)
			-- Extends current with `a_leg' at the end
		require
			leg_exists: a_leg /= void
			insertable: is_valid_for_insertion(a_leg.segments.first)
			not_joinable: (last = void) or else  (not last.is_joinable (a_leg))
		do
			if first = void then
				set_first(a_leg)
			else
				last.set_next (a_leg)
			end
			if after then
				item := a_leg
			end
		ensure
			one_more: count = old count +1
		end


	append (a_route: TRAFFIC_ROUTE)
			-- Append a TRAFFIC_ROUTE `a_route' at the end of the actual route
		require
			route_exists: a_route /= VOID
			route_valid_for_insertion: is_valid_for_insertion(a_route.first.segments.first)
		local
			leg: TRAFFIC_LEG
		do
			leg := last
			if first = Void then
				set_first (a_route.first)
			else
				if leg.is_joinable (a_route.first) then
					leg.join (a_route.first)
				else
					leg.set_next (a_route.first)
				end
			end
		end

	set_first(a_leg: TRAFFIC_LEG)
			-- sets pointer 'first' to the 'a_leg'
		require
			a_leg_exists: a_leg /= Void
		do
			if not(a_leg.origin.name.is_equal (a_leg.destination.name)) then
					--don't make intra-station leg
				first := a_leg
			end
		end

	set_scale_factor (a_scale_factor: REAL_64)
			-- sets the scale factor
		require
			a_scale_factor_exists: a_scale_factor /= Void
		do
			scale_factor := a_scale_factor
		end



feature -- Iteration

	new_cursor: TRAFFIC_ROUTE
			-- <Precursor>
			-- TODO review
		do
			Result := twin
			Result.start
		end

feature -- Cursor movement

	start
			-- Move to first position if any.
		do
			if first /= Void then
				item := first
				after := False
			else
				after := True
			end
		end

	forth
			-- Move to next position; if no next position,
			-- ensure that `exhausted' will be true.
		do
			if item /= Void and then item.next /= Void then
				item := item.next
			else
				after := True
			end
		end

	finish
			-- Move cursor to last position.
			-- (Go before if empty)
		do
			item := last
			after := False
		end

feature {NONE} -- Implementation

	scale_factor: REAL_64
			-- Scale factor for real world distances

invariant

	scale_factor_valid: scale_factor > 0

end
