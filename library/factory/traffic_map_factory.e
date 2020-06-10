note
	description : "Factory for traffic elements like TRAFFIC_STATION, TRAFFIC_LINE etc."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_MAP_FACTORY

inherit
	TRAFFIC_TYPE_FACTORY
		rename
			make as make_type_factory,
			build as build_traffic_type
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
			make_type_factory
			reset_factory
		ensure then
			everything_void: internal_map = Void and
							 internal_station = Void and
							 internal_one_direction = Void and
							 internal_other_direction = Void and
							 internal_line = Void
							 internal_road=Void
		end

feature -- Initialization

	reset_factory
			-- Reset traffic map factory.
		do
			internal_map := Void
			internal_station := Void
			internal_one_direction := Void
			internal_other_direction := Void
			internal_line := Void
		ensure
			everything_void: internal_map = Void and
							 internal_station = Void and
							 internal_one_direction = Void and
							 internal_other_direction = Void and
							 internal_line = Void
							 internal_road= Void
		end

feature -- Traffic city building

	build_city (a_name: STRING)
			-- Generate new city object with name `a_name'.
			-- (Access generated object through feature `city')
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			create internal_map.make (a_name)
		ensure
			city_created: city /= Void
			city_has_name: equal (city.name, a_name)
		end

	city: TRAFFIC_CITY
			-- Generated city object
		require
			city_available: has_city
		do
			Result := internal_map
		ensure
			Result_exists: Result /= Void
		end

	has_city: BOOLEAN
			-- Is traffic city object available?
		do
			Result := internal_map /= Void
		end

feature -- Traffic station building

	build_station (a_name: STRING; a_city: TRAFFIC_CITY)
			-- Generate new traffic station object with name `a_name' belonging to traffic map `a_city'.
			-- (Access generated object through feature `station')
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			city_exists: has_city
			unique_name: not a_city.stations.has (a_name)
		do
			create internal_station.make (a_name)
			a_city.stations.put (internal_station, internal_station.name)
		ensure
			created: station /= Void
			has_name: equal (station.name, a_name)
			in_city: a_city.stations.has (a_name)
		end

	build_station_with_position (a_name: STRING; a_x, a_y: INTEGER; a_city: TRAFFIC_CITY)
			-- Generate new traffic station object with name `a_name' and
			-- position (`a_x', `a_y') belonging to traffic map `a_city'.
			-- (Access generated object through feature `station')
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			city_exists: has_city
			unique_name: not a_city.stations.has (a_name)
		do
			create internal_station.make_with_location (a_name, a_x, a_y)
			a_city.stations.put (internal_station, internal_station.name)
		ensure
			created: station /= Void
			has_name: equal (station.name, a_name)
			in_city: a_city.stations.has (a_name)
		end

	station: TRAFFIC_STATION
			-- Generated traffic station object
		require
			is_available: has_station
		do
			Result := internal_station
		ensure
			Result_exists: Result /= Void
		end

	has_station: BOOLEAN
			-- Is traffic station object available?
		do
			Result := internal_station /= Void
		end

feature -- Traffic station building

	build_landmark (x, y: INTEGER; a_name: STRING; a_city: TRAFFIC_CITY; a_filename: STRING)
			-- Generate new traffic landmark object with name `a_name' belonging to traffic map `a_city'.
			-- (Access generated object through feature `landmark')
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			city_exists: has_city
			unique_name: not a_city.landmarks.has (a_name)
		local
			pos: TRAFFIC_POINT
		do
			create pos.make (x, y)
			create internal_landmark.make (pos, a_name, a_filename)
			a_city.landmarks.put (internal_landmark, internal_landmark.name)
		ensure
			created: landmark /= Void
			has_name: equal (landmark.name, a_name)
			in_city: a_city.landmarks.has (a_name)
		end

	landmark: TRAFFIC_LANDMARK
			-- Generated traffic landmark object
		require
			is_available: has_landmark
		do
			Result := internal_landmark
		ensure
			Result_exists: Result /= Void
		end

	has_landmark: BOOLEAN
			-- Is traffic landmark object available?
		do
			Result := internal_landmark /= Void
		end

feature -- Line segment building

	build_line_segment (a_origin, a_destination:STRING; a_polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT]; a_city: TRAFFIC_CITY; a_line: TRAFFIC_LINE)
			-- Generate new traffic line segment object going from origin `a_origin' to `a_destination'
			-- belonging to line `a_line' in map `a_city'.
			-- (Access the generated object through feature `line_segments')
		require
			a_city_exists: a_city /= Void
			a_origin_exists: a_city.stations.has (a_origin)
			a_destination_exists: a_city.stations.has (a_destination)
			a_line_exists: a_line /= Void
		local
			pps: DS_ARRAYED_LIST [TRAFFIC_POINT]
			origin_s: TRAFFIC_STATION
			destination_s: TRAFFIC_STATION
			origin_stop: TRAFFIC_STOP
			destination_stop: TRAFFIC_STOP
			stop_pos: TRAFFIC_POINT
		do
			if a_polypoints = Void or else a_polypoints.count < 2 then
				create pps.make (2)
				pps.force_last (a_city.stations.item (a_origin).location)
				pps.force_last (a_city.stations.item (a_destination).location)
			else
				pps := a_polypoints
			end
			origin_s := a_city.stations.item (a_origin)
			destination_s := a_city.stations.item (a_destination)

			if origin_s.has_stop (a_line) then
				origin_stop := origin_s.stop (a_line)
			else
				create stop_pos.make_from_other (pps.first)
				create origin_stop.make_with_location (origin_s, a_line, stop_pos) --, a_polypoints.first.x, a_polypoints.first.y)
			end

			if destination_s.has_stop (a_line) then
				destination_stop := destination_s.stop (a_line)
			else
				create stop_pos.make_from_other (pps.last)
				create destination_stop.make_with_location (destination_s, a_line, stop_pos) --, a_polypoints.first.x, a_polypoints.first.y)
			end

			create internal_one_direction.make (origin_stop, destination_stop, a_line.type, pps)

			if a_polypoints = Void or else a_polypoints.count < 2 then
				create pps.make (2)
				pps.force_last (a_city.stations.item (a_destination).location)
				pps.force_last (a_city.stations.item (a_origin).location)
			else
				pps := a_polypoints
			end
			origin_s := a_city.stations.item (a_destination)
			destination_s := a_city.stations.item (a_origin)

			if origin_s.has_stop (a_line) then
				origin_stop := origin_s.stop (a_line)
			else
				create stop_pos.make_from_other (pps.first)
				create origin_stop.make_with_location (origin_s, a_line, stop_pos) --, a_polypoints.first.x, a_polypoints.first.y)
			end

			if destination_s.has_stop (a_line) then
				destination_stop := destination_s.stop (a_line)
			else
				create stop_pos.make_from_other (pps.last)
				create destination_stop.make_with_location (destination_s, a_line, stop_pos) --, a_polypoints.first.x, a_polypoints.first.y)
			end
			create internal_other_direction.make (origin_stop, destination_stop, a_line.type, pps)
			a_line.put_last (internal_one_direction, internal_other_direction)
		ensure
			line_segment_created: connection_one_direction /= Void and connection_other_direction /= Void
			line_segment_has_line: connection_one_direction.line = a_line and connection_other_direction.line = a_line
			line_segment_has_type: equal (connection_one_direction.type, a_line.type) and equal (connection_one_direction.type, a_line.type)
			line_segment_has_origin: connection_one_direction.origin = a_city.stations.item (a_origin) and connection_other_direction.destination = a_city.stations.item (a_origin)
			line_segment_has_destination: connection_one_direction.destination = a_city.stations.item (a_destination) and connection_other_direction.origin = a_city.stations.item (a_destination)
		end

	connection_one_direction: TRAFFIC_LINE_SEGMENT
			-- Generated traffic line segment object
		require
			line_segment_available: has_line_segment
		do
			Result := internal_one_direction
		ensure
			Result_exists: Result /= Void
		end

	connection_other_direction: TRAFFIC_LINE_SEGMENT
			-- Generated traffic line segment object
		require
			line_segment_available: has_line_segment
		do
			Result := internal_other_direction
		ensure
			Result_exists: Result /= Void
		end

	has_line_segment: BOOLEAN
			-- Is there a line segment object available?
		do
			Result := internal_one_direction /= Void and internal_other_direction /= Void
		end

feature -- Road segment building

	build_road (a_origin, a_destination:STRING; a_city: TRAFFIC_CITY; a_type: STRING; an_id:STRING; a_direction:STRING)
			-- Generate new traffic road object going from origin `a_origin' to `a_destination'
			-- belonging to `a_city'.
			-- (Access the generated object through feature `road')
		require
			a_city_exists: a_city /= Void
			a_origin_exists: a_city.stations.has (a_origin)
			a_destination_exists: a_city.stations.has (a_destination)
			an_id_exists: an_id/=Void
			a_type_exists: a_type/=Void
			a_direction_exists: a_direction/=Void
		local
			way1, way2: TRAFFIC_ROAD_SEGMENT
		do
			way1 := create_road_connection (a_origin, a_destination, a_city, a_type, an_id)
			if a_direction.is_equal ("undirected") then
				way2 := create_road_connection (a_destination, a_origin, a_city, a_type, an_id)
				create internal_road.make (way1, way2)
			else
				create internal_road.make_one_way (way1)
			end
			a_city.roads.put (internal_road, internal_road.id)
		ensure
			road_created: road /= Void
		end

	road: TRAFFIC_ROAD
			-- Generated traffic road object
		require
			road_available: has_road
		do
			Result := internal_road
		ensure
			Result_exists: Result /= Void
		end

	has_road: BOOLEAN
			-- Is there a road object available?
		do
			Result := internal_road /= Void
		end

feature -- Traffic line building

	build_line (a_name: STRING; a_type_name: STRING; a_city: TRAFFIC_CITY)
			-- Generate new traffic line object with name `name' and type `type'
			-- belonging to map `a_city'.
			-- (Access the generated object through feature `line')
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
			a_city_exists: a_city /= Void
			type_name_is_valid: valid_name (a_type_name)
		local
			actual_traffic_type: TRAFFIC_TYPE_LINE
		do
			build_traffic_type (a_type_name)
			actual_traffic_type ?= internal_traffic_type
			create internal_line.make (a_name, actual_traffic_type)
			a_city.lines.put (internal_line, internal_line.name)
		ensure
			line_created: line /= Void
			line_has_name: equal (line.name, a_name)
			line_has_type: equal (line.type.name, a_type_name)
			line_in_city: a_city.lines.has (a_name)
		end

	line: TRAFFIC_LINE
			-- Generated traffic line object
		require
			line_available: has_line
		do
			Result := internal_line
		ensure
			Result_exists: Result /= Void
		end

	has_line: BOOLEAN
			-- Is there a traffic line object available?
		do
			Result := internal_line /= Void
		end

feature {NONE} -- Implementation

	traffic_type_factory: TRAFFIC_TYPE_FACTORY
			-- Traffic type factory

	internal_station: TRAFFIC_STATION
			-- Internal representation of last created traffic station

	internal_landmark: TRAFFIC_LANDMARK
			-- Internal representation of last created traffic landmark

	internal_one_direction, internal_other_direction: TRAFFIC_LINE_SEGMENT
			-- Internal representation of last created traffic line segment

	internal_line: TRAFFIC_LINE
			-- Internal representation of last created traffic line

	internal_road: TRAFFIC_ROAD
			-- Internal representation of last created traffic road

	internal_map: TRAFFIC_CITY
			-- Internal representation of last created traffic map

	create_road_connection (a_origin, a_destination: STRING; a_city: TRAFFIC_CITY; a_type:STRING;an_id:STRING): TRAFFIC_ROAD_SEGMENT
			-- Create road with type `a_type', origin `a_origin', destination `a_destination' belonging to line `a_city'.
		require
			a_origin_exists: a_origin /= Void
			a_origin_not_empty: not a_origin.is_empty
			a_origin_in_city: a_city.stations.has (a_origin)
			a_destination_exists: a_destination /= Void
			a_destination_not_empty: not a_destination.is_empty
			a_destination_in_city: a_city.stations.has (a_destination)
			a_type_exists: a_type/=Void
			an_id_exists: an_id/=Void
		local
			a_road: TRAFFIC_ROAD_SEGMENT
			origin_s: TRAFFIC_STATION
			destination_s: TRAFFIC_STATION
			type: TRAFFIC_TYPE_ROAD
			i: INTEGER
			origin_node: TRAFFIC_NODE
			destination_node: TRAFFIC_NODE
		do
			origin_s := a_city.stations.item (a_origin)
			destination_s := a_city.stations.item (a_destination)

			origin_node := origin_s.dummy_node
			destination_node := destination_s.dummy_node

			create traffic_type_factory.make
			traffic_type_factory.build(a_type)
			type?= traffic_type_factory.traffic_type
			i:=an_id.to_integer
			create a_road.make (origin_node, destination_node, type, i)
			Result := a_road
		ensure
			result_exists: Result /= Void
		end

end
