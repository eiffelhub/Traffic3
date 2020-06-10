note
	description: "Stops that belong to a line and are nodes of the graph"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_STOP

inherit
	TRAFFIC_NODE
		redefine
			hash_code,
			out,
			put_connection
		end

create
	set_station_and_line, make_with_location

feature {NONE} -- Creation

	set_station_and_line (s: TRAFFIC_STATION; l: TRAFFIC_LINE) 
			-- Associate this stop with station `s' and line `l'.
		require
			station_exists: s /= Void
			line_exists: l /= Void
		do
			make_with_station (s, s.location.twin)
			line := l
			station.add_stop (Current)
		ensure
			station_set: station = s
			line_set: line = l
		end

	make_with_location (a_station: TRAFFIC_STATION; a_line: TRAFFIC_LINE; a_location: TRAFFIC_POINT)
			-- Initialize `Current'.
		require
			station_not_void: a_station /= Void
			line_not_void: a_line /= Void
			location_not_void: a_location /= Void
		do
			make_with_station (a_station, a_location)
			line := a_line
			station.add_stop (Current)
		ensure
			stop_added: station.stops.has (Current)
			station_set: station = a_station
			line_set: line = a_line
			connection_list_exists: connection_list /= Void
			item_set: item = Current
		end

feature -- Access

	name: STRING
			-- "Unique" name
		do
			Result := station.name + line.name
		end

	line: TRAFFIC_LINE
			-- Line this stop belongs to

	hash_code: INTEGER
			-- Hash code value
		do
			Result := ([station.name, line.name]).hash_code
		end

	right: TRAFFIC_STOP
			-- Next stop on same line

	segment_to_right: TRAFFIC_LINE_SEGMENT
			-- The segment leading to `right'
		require
			right_exists: right /= void
		local
			i: INTEGER
		do
			from
				connection_list.start
				i := 1
			until
				i > connection_list.count
			loop
				if connection_list.item.destination.stop (line) = right then
					Result ?= connection_list.item
				end
				connection_list.forth
				i := i+1
			end
		end

	time_to_next: REAL_64
		-- Estimated travel time to next stop (departure to departure,
		-- except for next-to-last stop: departure to arrival).
		require
			has_next: right /= Void
		do
			Result := segment_to_right.travel_time (line.type.speed)
		end


feature -- Basic operations

	put_connection (a_connection: TRAFFIC_SEGMENT)
			-- Insert `a_connection'.
		local
			c: TRAFFIC_LINE_SEGMENT
		do
			connection_list.extend (a_connection)
			changed_event.publish ([])
			c ?= a_connection
			if c /= Void then
				right := c.end_node
			end
		end

	link (s: TRAFFIC_STOP)
			-- Make `s' the next stop on the line.
		require
			s_exists: s /= Void
		local
			l1, l2: TRAFFIC_LINE_SEGMENT
			pp: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			create pp.make (2)
			pp.put_last (location.twin)
			pp.put_last (s.location.twin)
			create l1.make (Current, s, line.type, pp)
			create pp.make (2)
			pp.put_last (s.location.twin)
			pp.put_last (location.twin)
			create l2.make (s, Current, line.type, pp)
			line.put_last (l1, l2)
			right := s
		ensure
			right_set: right = s
		end


feature -- Output

	out: STRING
			-- Info about stop
		do
			Result := "Traffic stop:%NStation: " + station.name + "%NLine: " + line.name
		end

invariant

	line_not_void: line /= Void
	item_is_self: item = Current
	connection_list_exists: connection_list /= Void
	station_not_void: station /= Void
	stop_is_in_station: station.stops.has (Current)

end
