note
	description: "Class for taxi offices"
	date: "$Date$"
	revision: "$Revision$"

class TRAFFIC_TAXI_OFFICE

inherit

	DOUBLE_MATH
		redefine
			default_create
		end

	TRAFFIC_CONSTANTS
		export {NONE} all
		redefine
			default_create
		end

	TRAFFIC_CITY_ITEM
		undefine
			default_create
		redefine
			add_to_city,
			remove_from_city
		end
create
	default_create, make_with_color


feature {NONE} -- Initialization

	default_create
			-- Initialize lists.
		do
			create available_taxis.make
			create taxis.make
			create color.make_with_rgb (255, 255, 255)
			create changed_event
		ensure then
			taxis_exists: taxis /= Void
			available_taxis_exists: available_taxis /= Void
			color_exists: color /= Void
		end

	make_with_color (r, g, b: INTEGER)
			-- Set `color' to rgb values.
		require
			r_valid: r >= 0 and r <= 255
			g_valid: g >= 0 and g <= 255
			b_valid: b >= 0 and b <= 255
		do
			default_create
			create color.make_with_rgb (r, g, b)
			create changed_event
		end


feature -- Access

	available_taxis: TRAFFIC_EVENT_LINKED_LIST[TRAFFIC_DISPATCH_TAXI]
			-- Available taxis (not busy)

	taxis: TRAFFIC_EVENT_LINKED_LIST [TRAFFIC_DISPATCH_TAXI]
			-- All taxis that work for this office

	color: TRAFFIC_COLOR
			-- Color of the taxi office


feature -- Basic operations

	add_taxi (a_taxi: TRAFFIC_DISPATCH_TAXI)
			-- Add `a_taxi' to the taxi_list of the office.
		require
			a_taxi_valid: a_taxi /= Void
		do
			available_taxis.force_last(a_taxi)
			taxis.force_last (available_taxis.last)
			if is_in_city and then not city.taxis.has (a_taxi) then
				city.put_taxi (a_taxi)
			end
		end

	remove_taxi (a_taxi:TRAFFIC_DISPATCH_TAXI)
			-- Remove `a_taxi' from current taxi office.
		require
			a_taxi_valid: a_taxi /= Void
		do
			available_taxis.delete (a_taxi)
			taxis.delete (a_taxi)
			if a_taxi.is_in_city then
				city.taxis.delete (a_taxi)
			end
		end


	call (from_location:TRAFFIC_POINT; to_location:TRAFFIC_POINT)
			-- Determine nearest taxi to from_location station, pass request on to this taxi.
		require
			from_location_not_void: from_location /= void
			to_location_not_void: to_location /= void
		local
			nearest_taxi: TRAFFIC_TAXI
			minimum_distance: REAL_64
			temp_distance: REAL_64
			position: TRAFFIC_POINT
		do
			if available_taxis.count > 0 then
				nearest_taxi := available_taxis.first
				position := available_taxis.first.location
				minimum_distance := sqrt((from_location.x - position.x)^2 + (from_location.y - position.y)^2)
				from
					available_taxis.start
					available_taxis.forth
					-- To start on second item on taxi_list.
				until
					available_taxis.after
				loop
					position :=available_taxis.item_for_iteration.location
					temp_distance := sqrt((from_location.x - position.x)^2 + (from_location.y - position.y)^2)
					if minimum_distance > temp_distance then
						minimum_distance := temp_distance
						nearest_taxi := available_taxis.item_for_iteration
					end
					available_taxis.forth
				end
				nearest_taxi.take(from_location, to_location)
			end
		end

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


feature {TRAFFIC_ITEM_LINKED_LIST} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all taxis to `a_city'.
		do
			is_in_city := True
			city := a_city
			from
				taxis.start
			until
				taxis.after
			loop
				if not city.taxis.has (taxis.item_for_iteration) then
					city.taxis.put (taxis.item_for_iteration)
				end
				taxis.forth
			end
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			from
				taxis.start
			until
				taxis.off
			loop
				taxis.item_for_iteration.remove_from_city
				taxis.forth
			end
			is_in_city := False
			city := Void
		end

feature {TRAFFIC_DISPATCH_TAXI} -- Basic operations for taxis

	enlist(a_taxi:TRAFFIC_DISPATCH_TAXI)
			-- Put a_taxi into available list.
		require
			a_taxi_not_busy: a_taxi.busy = false
		do
			available_taxis.force_last(a_taxi)

		ensure
			a_taxi_added: available_taxis.count = old available_taxis.count + 1
		end

	delist(a_taxi: TRAFFIC_DISPATCH_TAXI)
			-- Take a_taxi out of available_taxi_list.
		require
			a_taxi_not_available: a_taxi.busy = true
		do
			if available_taxis.has(a_taxi)
				then
					available_taxis.delete(a_taxi)
				end
		end

	recall(from_location: TRAFFIC_POINT; to_location: TRAFFIC_POINT)
			-- Recall the request again because a taxi rejected to take it.
		require
			from_location_not_void: from_location /= void
			to_location_not_void: to_location /= void
		do
			call(from_location, to_location)
		end

invariant
	taxis_exists: taxis /= Void
	available_taxis_exists: available_taxis /= Void
	color_set: color /= Void

end
