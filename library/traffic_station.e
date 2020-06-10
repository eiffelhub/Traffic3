note
	description: "Stations (or more generally places connected through lines or roads)"
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"

class
	TRAFFIC_STATION

inherit
	HASHABLE
		redefine
			out
		end

	TRAFFIC_CITY_ITEM
		undefine
			out,
			add_to_city,
			remove_from_city
		end

create
	make, make_with_location

feature {NONE} -- Initialize

	make (a_name: STRING)
			-- Initilize `Current'.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			name := a_name
			create changed_event
			create schedule.make
			create stops.make (5)
			create nodes.make (5)
			create dummy_node.make_with_station (Current, create {TRAFFIC_POINT}.make (0.0, 0.0))
			add_node (dummy_node)
		ensure
			name_set: equal (a_name, name)
			location_exists: location /= Void
		end

	make_with_location (a_name: STRING; a_x, a_y: INTEGER)
			-- Initialize `Current' with name `a_name' and location `a_x', `a_y'.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			name := a_name
			create changed_event
			create dummy_node.make_with_station (Current, create {TRAFFIC_POINT}.make (a_x, a_y))
			create schedule.make
			create stops.make (5)
			create nodes.make (5)
			add_node (dummy_node)
		ensure
			name_set: equal (a_name, name)
			location_exists: location /= Void
			location_set: location.x = a_x and location.y = a_y
		end

feature -- Access

	outgoing_line_connections: DS_ARRAYED_LIST [TRAFFIC_LINE_SEGMENT]
			-- All outgoing line connections
		local
			l: TWO_WAY_CIRCULAR [TRAFFIC_SEGMENT]
			c: TRAFFIC_LINE_SEGMENT
			i: INTEGER
		do
			create Result.make (5)
			from
				stops.start
			until
				stops.after
			loop
				from
					l := stops.item.connection_list
					i := 1
				until
					i > l.count
				loop
					c ?= l.i_th (i)
					if c /= Void and then c.destination /= c.origin then
						Result.force_last (c)
					end
					i := i + 1
				end
				stops.forth
			end
		end


	name: STRING
			-- Name of station

	location: TRAFFIC_POINT
			-- Location on city
		do
			Result := dummy_node.location
		end

	information: TRAFFIC_STATION_INFORMATION
			-- Additional information.

	schedule: LINKED_LIST[TUPLE[TRAFFIC_LINE_VEHICLE, TIME, TRAFFIC_STATION]]
			-- All departure times [tram, time, direction] of trams visiting this station

	nodes: ARRAYED_LIST [TRAFFIC_NODE]
			-- Nodes that belong to this station

	stops: ARRAYED_LIST[TRAFFIC_STOP]
			-- All stops of lines stoping at this station

	dummy_node: TRAFFIC_NODE
			-- Node used for shortest route calculation

	stop (a_line: TRAFFIC_LINE): TRAFFIC_STOP
			-- Stop belonging to `a_line'
		do
			from stops.start until stops.after or stops.item.line.name.is_equal (a_line.name) loop
				stops.forth
			end
			if not stops.after then
				Result := stops.item
			end
		end

	width: REAL_64
			-- Width of the station (enclosing all stops)

	breadth: REAL_64
			-- Breadth of the station (enclosing all stops)

	hash_code: INTEGER
			-- Hash code value
		do
			Result := name.hash_code
		end

	lines: LINKED_SET[TRAFFIC_LINE]
			-- Returns all the lines used by stops of `current'
		do
			create result.make
			from
				stops.start
			until
				stops.after
			loop
				if not result.has(stops.item.line) then
					result.extend(stops.item.line)
				end
				stops.forth
			end
		end


feature -- Status report

	is_exchange: BOOLEAN
			-- Is this an exchange station (where multiple transportation lines stop)
		do
			if outgoing_line_connections.count > 2 then
				Result := True
			end
		ensure
			is_exchange: Result = (outgoing_line_connections.count > 2)
		end

	 is_railway_connection: BOOLEAN
             -- Is this a railway connection
        require
            not_empty: not outgoing_line_connections.is_empty
        local
            found: BOOLEAN
            i: INTEGER
        do

               from
                    i:=1
               until
                    i = outgoing_line_connections.count + 1
               loop
                    if outgoing_line_connections.item(i).type.name.is_equal("rail") then
                         found:= True
                    end
                    i := i+1
               end
               result:= found

          end

	is_hub: BOOLEAN
			-- Is this an exchange station (where multiple transportation lines stop)
		do
			if outgoing_line_connections.count > Hub_size then
				Result := True
			end
		ensure
			is_exchange: Result implies is_exchange
			is_hub: Result = (outgoing_line_connections.count > Hub_size)
		end

	has_stop (a_line: TRAFFIC_LINE): BOOLEAN
			-- Does the station have a stop for `a_line'?
		require
			a_line_exists: a_line /= Void
		do
			Result := stops.there_exists (agent is_stop_of_line (?, a_line))
		end

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- (All nodes need to be insertable. See `TRAFFIC_NODE is_insertable' for requirements.)
		do
			Result := True
			from
				nodes.start
			until
				nodes.off or not Result
			loop
				if not nodes.item.is_insertable (a_city) then
					Result := False
				end
				nodes.forth
			end
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
			-- Only internal exchange connections are allowed...
		local
			l: TWO_WAY_CIRCULAR [TRAFFIC_SEGMENT]
			ex: TRAFFIC_EXCHANGE_SEGMENT
			i: INTEGER
		do
			Result := True
			from
				nodes.start
			until
				nodes.after
			loop
				l := nodes.item.connection_list
				from
					i := 1
				until
					i > l.count
				loop
					ex ?= l.i_th (i)
					if ex = Void then
						Result := False
					end
					i := i + 1
				end
				nodes.forth
			end
		end

	is_road_connected(a_station: TRAFFIC_STATION): BOOLEAN
			-- Is `a_station' reachable through one road in the city?
		local
			roads: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_ROAD, INTEGER]
		do
			roads := city.roads
			from
				roads.start
			until
				roads.after or result
			loop
				if roads.item_for_iteration.connects (current, a_station) then
					result := true
				end
				roads.forth
			end
		end

	connecting_road(a_station: TRAFFIC_STATION): TRAFFIC_ROAD
			-- A (arbitrary) road connection `current' and `a_station'
		require
			connected: is_road_connected(a_station)
		local
			roads: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_ROAD, INTEGER]
		do
			roads := city.roads
			from
				roads.start
			until
				roads.after or (result /= void)
			loop
				if roads.item_for_iteration.connects (current, a_station) then
					result := roads.item_for_iteration
				end
				roads.forth
			end

		end



feature {TRAFFIC_ITEM_LINKED_LIST}-- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all nodes to `a_city'.
		do
			is_in_city := True
			city := a_city
			from
				nodes.start
			until
				nodes.after
			loop
				nodes.item.add_to_city (a_city)
				nodes.forth
			end
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			from
				nodes.start
			until
				nodes.after
			loop
				nodes.item.remove_from_city
				nodes.forth
			end
			is_in_city := False
			city := Void
		end

feature -- Element change

	set_information (a_information: TRAFFIC_STATION_INFORMATION)
			-- Set information to `a_information'.
		require
			a_information_exists: a_information /= Void
		do
			information := a_information
			changed_event.publish ([])
		ensure
			information_set: information = a_information
		end

	set_location (a_location: TRAFFIC_POINT)
			-- Set location to `a_location'.
		require
			a_location_exists: a_location /= Void
		do
			dummy_node.set_location (a_location)
			changed_event.publish ([])
		ensure
			location_set: location = a_location
		end

feature -- Basic operations

	register_in_schedule (an_object: TRAFFIC_LINE_VEHICLE; time: TIME; target: TRAFFIC_STATION)
			-- Register a visiting tram in the schedule.
		require
			valid_object: an_object /= Void
			valid_time: time /= Void
			valid_target: target /= Void
		local
			entry: TUPLE[TRAFFIC_LINE_VEHICLE, TIME, TRAFFIC_STATION]
		do
			create entry
			entry.put (an_object, 1)
			entry.put (time, 2)
			entry.put (target, 3)
			schedule.extend (entry)
		end

feature {TRAFFIC_NODE} -- Insertion

	add_stop (a_stop: TRAFFIC_STOP)
			-- add a traffic stop
		require
			is_insertable: a_stop.is_insertable (city)
		do
			stops.extend (a_stop)
			nodes.extend (a_stop)
			update_location
			if is_in_city then
				a_stop.add_to_city (city)
			end
			changed_event.publish ([])
		end

	add_node (a_node: TRAFFIC_NODE)
			-- Add `a_node' to `Current'.
		local
			s: TRAFFIC_STOP
		do
			s ?= a_node
			if s /= Void then
				add_stop (s)
			else
				nodes.extend (a_node)
				if is_in_city then
					a_node.add_to_city (city)
				end
			end
			changed_event.publish ([])
		end

feature -- Output

	out: STRING
			-- Textual representation of station
		local
			information_string: STRING
		do
			if information /= Void then
				information_string := ", "
				if information.pictures.count > 0 then
					information_string := information_string + " pictures: "
					from
						information.pictures.start
					until
						information.pictures.after
					loop
						information_string := information_string + information.pictures.item
						information.pictures.forth
						if not information.pictures.after then
							information_string := information_string + ", "
						end
					end
				end
				if information.description /= Void and information.pictures.count > 0 then
					information_string := information_string + ","
				end
				if information.description /= Void then
					information_string := information_string + " description: " + information.description
				end
			else
				information_string := ""
			end
			Result := "Traffic station " + name + " at location " + location.out + information_string
		end

feature -- Constants

	Hub_size: INTEGER = 8
			-- A station is considered a hub if it has more than `Hub_size' outgoing connections (or since lines are bidirection `Hub_size'/2 lines)

feature {NONE} -- Implementation

	is_stop_of_line (a_stop: TRAFFIC_STOP; a_line: TRAFFIC_LINE): BOOLEAN
			-- Does `a_stop' service `a_line'?
		do
			Result := a_stop.line.name.is_equal (a_line.name)
		end

	update_location
			-- Update the location, breadth, and width of the station using the stop's line-segments locations.
			-- This strange hack with the line_segments is needed because of Touch of class.
		do
			if stops.count = 1 then
				width := 0
				breadth := 0
				set_location (stops.first.location)
			else
				if stops.last.location.x > location.x + width/2 then
					set_location (create {TRAFFIC_POINT}.make ((stops.last.location.x + location.x - width/2)/2, location.y))
					width := (stops.last.location.x - location.x)*2
				elseif stops.last.location.x < location.x - width/2 then
					set_location (create {TRAFFIC_POINT}.make ((stops.last.location.x + location.x + width/2)/2, location.y))
					width := (location.x - stops.last.location.x)*2
				end
				if stops.last.location.y > location.y + breadth/2 then
					set_location (create {TRAFFIC_POINT}.make (location.x, (stops.last.location.y + location.y - breadth/2)/2))
					breadth := (stops.last.location.y - location.y)*2
				elseif stops.last.location.y < location.y - breadth/2 then
					set_location (create {TRAFFIC_POINT}.make (location.x, (stops.last.location.y + location.y + breadth/2)/2))
					breadth := (location.y - stops.last.location.y)*2
				end
			end
		end

invariant
	name_valid: name /= Void and then not name.is_empty
	location_not_void: location /= Void
	stops_not_void: stops /= Void
	nodes_not_void: stops /= Void
	dummy_node_not_void: dummy_node /= Void
	station_in_city: is_in_city implies city.stations.has (name)

end
