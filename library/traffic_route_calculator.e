note
	description: "A route calculator facility"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ROUTE_CALCULATOR

create
	set_city

feature -- Access

	route: TRAFFIC_ROUTE
			-- Calculated shortest route

	city: TRAFFIC_CITY
			-- City on which the route is calculated

	shortest_path_mode: INTEGER
			-- Mode used for shortest path calculation (either normal or minimal switches)

	shortest_path_mode_normal_distance: INTEGER
			-- Number representing path calculation mode based on regular distance
		do
			Result := city.graph.normal_distance
		end

	shortest_path_mode_minimal_switches: INTEGER
			-- Number representing path calculation mode based on regular distance
		do
			Result := city.graph.minimal_switches
		end

feature -- Basic operations

	find_shortest_path (a_origin: TRAFFIC_STATION; a_destination: TRAFFIC_STATION)
			-- Find shortest route.
		require
			a_origin_exists: a_origin /= Void
			a_destination_exists: a_destination /= Void
			not_same: a_destination /= a_origin
		local
			temp_path: LIST [TRAFFIC_SEGMENT]
			current_ps, next_ps: TRAFFIC_LEG
			old_mode: INTEGER
		do
			old_mode := city.graph.shortest_path_mode
			city.graph.set_shortest_path_mode (shortest_path_mode)
			city.graph.find_shortest_path (a_origin.dummy_node, a_destination.dummy_node)

			if city.graph.path_found then
				is_route_found := True
				temp_path := city.graph.shortest_path
				create route
				route.set_scale_factor (city.scale_factor)

				from temp_path.start until temp_path.after loop
					if (not (temp_path.item.origin = temp_path.item.destination)) and (route.first = Void) then
							--don't make segment for intra-station connections
						create current_ps.make (temp_path.item)
						route.set_first (current_ps)
					else
						if not (temp_path.item.origin = temp_path.item.destination) then
								--don't make segment for intra-station connections
							create next_ps.make(temp_path.item)
							if current_ps.is_insertable (temp_path.item) then
									--same type of line
								current_ps.extend (temp_path.item)
							else
									--different type of line
								current_ps.set_next (next_ps)
								current_ps := next_ps
							end
						end
					end
					temp_path.forth
				end
			end
			city.graph.set_shortest_path_mode (old_mode)
		end

	find_shortest_path_of_a_list_of_stations(stations_to_visit: LINKED_LIST [TRAFFIC_STATION])
			-- Find shortest path given a list of stations `stations_to_visit'.
		require
			stations_to_visit_exists: stations_to_visit /= Void
			min_two_stations_to_visit: stations_to_visit.count > 1
		local
			a_path: TRAFFIC_ROUTE
			current_s, next_s: TRAFFIC_STATION
		do
			create a_path
			a_path.set_scale_factor (city.scale_factor)

			from
				stations_to_visit.start
			until
				stations_to_visit.after
			loop
				current_s := stations_to_visit.item
				stations_to_visit.forth
				if not stations_to_visit.after then
					next_s := stations_to_visit.item
					find_shortest_path(current_s, next_s)
					if is_route_found then
						a_path.append (route)
					end
				end
			end
			route := a_path
		end

feature -- Element change

	set_city (a_city: TRAFFIC_CITY)
			-- Set `city' to `a_city'.
		require
			a_city_exists: a_city /= Void
		do
			city := a_city
		ensure
			city_set: city = a_city
		end

	set_shortest_path_mode (a_mode: INTEGER)
			-- Set the shortest path mode to `a_mode'.
		require
			valide_mode: is_valid_shortest_path_mode (a_mode)
		do
			shortest_path_mode := a_mode
		ensure
			shortest_path_mode_set: shortest_path_mode = a_mode
		end

feature -- Status report

	is_valid_shortest_path_mode (a_mode: INTEGER): BOOLEAN 
			-- Is `a_mode' valid?
		do
			Result := a_mode = shortest_path_mode_minimal_switches or
					  a_mode = shortest_path_mode_normal_distance
		end

	is_route_found: BOOLEAN
			-- Was a shortest path found on graph?

invariant

	city_exists: city /= Void

end
