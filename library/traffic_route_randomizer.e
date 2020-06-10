note
	description: "Random route generator (used for providing passengers with their routes)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ROUTE_RANDOMIZER

create
	set_city

feature -- Element change

	set_city (a_city: TRAFFIC_CITY)
			-- Initialize with `a_city'.
		require
			a_city_exists: a_city /= Void
		local
			t: TIME
		do
			create t.make_now
			create random.set_seed (t.compact_time)
			random.start
			city := a_city
		ensure
			city_set: city = a_city
		end

feature -- Basic operations

	generate_route (n: INTEGER) 
			-- Generate a new route with at most `n' random connections to be taken on `city'.
			-- Result is accessable via `last_route'.
		require
			n_valid: n >= 1
			city_has_line_segment: city.line_segments.count >= 1
		local
			i: INTEGER
			pa: ARRAY [TRAFFIC_STATION]
			p: TRAFFIC_STATION
			no: TRAFFIC_NODE
			s,t: TRAFFIC_LEG
			finished: BOOLEAN
			c: TRAFFIC_SEGMENT
		do
			create last_route
			random.forth
			pa := city.stations.to_array
			-- The starting station
			p := pa.item (random.item \\ pa.count + 1)
			random.forth
			no := p.nodes.i_th (random.item \\ p.nodes.count + 1)
			from
				i := 1
			until
				i > n or finished
			loop
				random.forth
				if no.connection_list.count <= 0 then
					finished := True
				else
					c := no.connection_list.i_th (random.item \\ no.connection_list.count + 1)
					create t.make (c)
					if s /= void and s.is_joinable (t) then
						s.join (t)
					elseif s /= Void then
						s.set_next (t)
					else
						last_route.set_first (t)
					end
					if not c.is_directed then
						-- Find correct no
						if c.end_node /= no then
							no := c.end_node
						else
							no := c.start_node
						end
					else
						no := c.end_node
					end
				end
				s := t
				i := i + 1
			end
			-- Backup algorithm if the above did not find a route with at least one connection that is visible
			if last_route.first = Void then
				random.forth
				create t.make (city.line_segments.item (random.item \\ city.line_segments.count + 1))
				last_route.set_first (t)
			end
		ensure
			last_route_exists: last_route /= Void
		end

feature -- Access

	city: TRAFFIC_CITY
			-- City used for finding routes

	last_route: TRAFFIC_ROUTE
			-- Last route that was generated

feature {NONE} -- Implementation

	random: RANDOM
			-- Random number generator

invariant

	city_exists: city /= Void
	random_exists: random /= Void

end
