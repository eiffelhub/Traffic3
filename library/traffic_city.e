note
	description: "City with a traffic system of a region."
	date: "$Date: 2006/01/09 12:23:40 $"
	revision: "$Revision: 1.5 $"

class
	TRAFFIC_CITY

inherit

	STORABLE
		export
			{TRAFFIC_MAP_LOADER} all
		undefine
			out
		end

	DOUBLE_MATH
		redefine out end

	TRAFFIC_SHARED_TIME
		undefine out end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create an empty city with name `a_name'.
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		local
			default_size: INTEGER
		do
			default_size := 100
			name := a_name
			create graph.make
			create stations.make (default_size * default_size, Current)
			create lines.make (default_size, Current)
			create line_segments.make
			create roads.make (default_size, Current)
			create passengers.make (Current)
			create trams.make (Current)
			create busses.make (Current)
			create taxi_offices.make (Current)
			create taxis.make (Current)
			create routes.make (Current)
			create buildings.make (Current)
			create free_movings.make (Current)
			create landmarks.make (default_size, Current)
			create background_polygons.make
		ensure
			name_set: equal (name, a_name)
			stations_not_void: stations /= Void
			lines_not_void: lines /= Void
			line_segments_not_void: line_segments /= Void
		end

feature -- TODO

	display
			-- Just for the first example of touch of class.
		do
			-- Do nothing
		end

feature -- Status report

	station_at_location (a_point: TRAFFIC_POINT): TRAFFIC_STATION
			-- Station that `a_point' is located on
			-- Returns Void if there is no station at this location
		require
			a_point_exists: a_point /= Void
		local
			tolerance: REAL_64
		do
			tolerance := 2.0
			from
				stations.start
			until
				stations.after or Result /= Void
			loop
				if a_point.x > stations.item_for_iteration.location.x - stations.item_for_iteration.width/2 - tolerance and a_point.x < stations.item_for_iteration.location.x + stations.item_for_iteration.width/2 + tolerance and
					a_point.y > stations.item_for_iteration.location.y - stations.item_for_iteration.breadth/2 - tolerance and a_point.y < stations.item_for_iteration.location.y + stations.item_for_iteration.breadth/2 + tolerance then
					Result := stations.item_for_iteration
				end
				stations.forth
			end
		end

	closest_station (a_point: TRAFFIC_POINT): TRAFFIC_STATION
			-- Station cloasest to `a_point'
			-- Returns Void if there is no station
		require
			a_point_exists: a_point /= Void
		local
			l_dist, min_dist : REAL_64
		do
			from
				stations.start
				min_dist := stations.item_for_iteration.location.distance (a_point)
				Result := stations.item_for_iteration
				stations.forth
			until
				stations.after
			loop
				l_dist := stations.item_for_iteration.location.distance (a_point)
				if l_dist < min_dist then
					min_dist := l_dist
					Result := stations.item_for_iteration
				end
				stations.forth
			end
		ensure
			exists_if_stations_non_empty: (not stations.is_empty) implies (Result /= Void)
		end

feature -- Element change

	set_center (a_center: TRAFFIC_POINT)
			-- Set city center to `a_center'.
		require
			a_center_exists: a_center /= Void
		do
			center := a_center
		ensure
			center_set: center = a_center
		end

	set_radius (a_radius: REAL_64)
			-- Set city radius to `a_radius'.
		require
			a_radius_exists: a_radius /= Void
		do
			radius := a_radius
		ensure
			radius_set: radius = a_radius
		end

	set_description (a_description: STRING)
			-- Set city description.
		do
			description := a_description
		ensure
			description_set: description = a_description
		end

	set_scale_factor (a_scale_factor: REAL_64)
			-- Set `a_scale_factor'.
		require
			a_scale_factor_valid: a_scale_factor > 0
		do
			scale_factor := a_scale_factor
		ensure
			scale_factor_set: scale_factor = a_scale_factor
		end

feature -- Insertion

	put_station (a_station: TRAFFIC_STATION)
			-- Add `a_station' to `stations'
		require
			a_station_exists: a_station /= Void
		do
			stations.put (a_station, a_station.name)
		ensure
			station_added: stations.has (a_station.name)
		end

	put_line(a_line: TRAFFIC_LINE)
			-- Add `a_line' to `lines'.
		require
			a_line_exists: a_line /= void
		do
			lines.put (a_line, a_line.name)
		ensure
			line_added: lines.has (a_line.name)
		end

	put_road (a_road: TRAFFIC_ROAD)
			-- Add `a_road' to `roads'
		require
			a_road_exists: a_road /= Void
		do
			roads.put (a_road, a_road.id)
		ensure
			road_added: roads.has (a_road.id)
		end

	put_route (a_route: TRAFFIC_ROUTE)
			-- Add `a_route' to `routes'
		require
			a_route_exists: a_route /= Void
		do
			routes.put (a_route)
		ensure
			route_added:  routes.has(a_route)
		end

	put_building (a_building: TRAFFIC_BUILDING)
			-- Add `a_building' to `buildings'
		require
			a_building_exists: a_building  /= Void
		do
			buildings.put (a_building)
		ensure
			building_added:  buildings.has(a_building)
		end

	put_landmark (a_landmark: TRAFFIC_LANDMARK)
			-- Add `a_landmark' to `landmarks'
		require
			a_landmark_exists: a_landmark  /= Void
		do
			landmarks.put (a_landmark, a_landmark.name)
		ensure
			landmark_added:  landmarks.has(a_landmark.name)
		end

	put_taxi_office (a_taxi_office: TRAFFIC_TAXI_OFFICE)
			-- Add `a_taxi_office' to `taxi_offices'
		require
			a_taxi_office_exists: a_taxi_office  /= Void
		do
			taxi_offices.put (a_taxi_office)
		ensure
			taxi_office_added:  taxi_offices.has(a_taxi_office)
		end

	put_taxi (a_taxi: TRAFFIC_TAXI)
			-- Add `a_taxi' to `taxis'
		require
			a_taxi_exists: a_taxi  /= Void
		do
			taxis.put (a_taxi)
		ensure
			taxi_added:  taxis.has(a_taxi)
		end

	put_passenger (a_passenger: TRAFFIC_PASSENGER)
			-- Add `a_passenger' to `passengers'
		require
			a_passenger_exists: a_passenger  /= Void
		do
			passengers.put (a_passenger)
		ensure
			passenger_added:  passengers.has(a_passenger)
		end

	put_tram (a_tram: TRAFFIC_TRAM)
			-- Add `a_tram' to `trams'
		require
			a_tram_exists: a_tram  /= Void
		do
			trams.put (a_tram)
		ensure
			tram_added:  trams.has(a_tram)
		end

	put_bus (a_bus: TRAFFIC_BUS)
			-- Add `a_busse' to `busses'
		require
			a_bus_exists: a_bus  /= Void
		do
			busses.put (a_bus)
		ensure
			bus_added:  busses.has(a_bus)
		end

	put_free_moving (a_free_moving: TRAFFIC_FREE_MOVING)
			-- Add `a_free_moving' to `free_movings'
		require
			a_free_moving_exists: a_free_moving  /= Void
		do
			free_movings.put (a_free_moving)
		ensure
			free_moving_added:  free_movings.has(a_free_moving)
		end

feature -- Access

	center: TRAFFIC_POINT
			-- Location of the city center

	radius: REAL_64
			-- Radius of the city

	graph: TRAFFIC_GRAPH
			-- Graph used for calculating shortest routes

	name: STRING
			-- Name of region this city represents

	description: STRING
			-- Textual description of the city

	scale_factor: REAL_64
			-- Scale factor to reach real world distances
			-- Multiply with this to receive real-world distances

	background_polygons: LINKED_LIST[TRAFFIC_POLYGON]
			-- Polygons displaying the background of the city

feature -- Access (city objects)

	stations: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_STATION, STRING]
			-- All stations in city

	line_segments: DS_LINKED_LIST [TRAFFIC_LINE_SEGMENT]
			-- All line segments in city

	lines: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_LINE, STRING]
			-- All lines in city

	roads: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_ROAD, INTEGER]
			-- All roads in city

	routes: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_ROUTE]
			-- All routes in the city

	buildings: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_BUILDING]
			-- Buildings of the city

	landmarks: TRAFFIC_ITEM_HASH_TABLE [TRAFFIC_LANDMARK, STRING]
			-- Landmarks of the city

	taxi_offices: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_TAXI_OFFICE]
			-- All taxi offices associated with this city

	taxis: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_TAXI]
			-- All taxis associated with this city

	passengers: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_PASSENGER]
			-- All passengers moving around the city

	trams: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_TRAM]
			-- All trams in the city

	busses: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_BUS]
			-- All busses in the city

	free_movings: TRAFFIC_ITEM_LINKED_LIST [TRAFFIC_FREE_MOVING]
			-- All free moving objects in the city

feature -- Access

	line_segments_of_stop (a_name: STRING; a_line: TRAFFIC_LINE): LIST [TRAFFIC_LINE_SEGMENT]
			-- Line segments (2 or 1) of the stop specified by `a_name' for the line `a_line'
		require
			stations.has (a_name) and then stations.item (a_name).has_stop (a_line)
		local
			a_segments: LIST [TRAFFIC_SEGMENT]
			ls: TRAFFIC_LINE_SEGMENT
		do
			Result := create {ARRAYED_LIST [TRAFFIC_LINE_SEGMENT]}.make (2)
			graph.search (stations.item (a_name).stop (a_line))
			a_segments := graph.incident_edges
			from a_segments.start until a_segments.after loop
				ls ?= a_segments.item
				if ls /= Void then
					Result.extend (ls)
				end
				a_segments.forth
			end
		end

	Map_title: STRING = "Plan of the transport network"

feature -- Output

	out: STRING
			-- Textual representation.
		do
			Result := "Traffic city%Nnamed: " + name + "%Ndescription: " + description_out +
				"%N%Nstations:%N" + stations.out
		end

feature {TRAFFIC_MAP_LOADER}

	recalculate_weights_and_connect_stops
			-- Due to an error in processing the weights need to be recalculated.
			-- In addition, the stops of different lines are connected at nodes.
		local
			the_edges: LIST[TRAFFIC_SEGMENT]
			total_weight: REAL_64
			average_weight: REAL_64
			w: REAL_64
			edge_count: INTEGER
		do
			-- Recalculate edge weights.
			the_edges := graph.edges
			from
				the_edges.start
			until
				the_edges.after
			loop
				w := the_edges.item.length
				the_edges.item.set_weight (w)
				total_weight := total_weight + w
				edge_count := edge_count + 1
				the_edges.forth
			end

			if edge_count > 0 then
				average_weight := total_weight / edge_count
			end
		end

feature {NONE}-- Implementation

	station_location (a_name: STRING): INTEGER
			-- Location of station `a_name' in stations
		require
			a_name_exists: a_name /= Void
			a_name_not_exmpa: not a_name.is_empty
			a_name_in_stations: stations.has (a_name)
		local
			i: INTEGER
		do
			from
				i := 1
				stations.start
			until
				stations.item_for_iteration.name.is_equal (a_name)
			loop
				i := i + 1
				stations.forth
			end
			Result := i
		end


	description_out: STRING
			-- Textual representation of description
		do
			if description = Void then
				Result := ""
			else
				Result := description
			end
		ensure
			Result_exists: Result /= Void
		end

	location_from_segmentss (a_segments: LIST [TRAFFIC_SEGMENT]; a_node: TRAFFIC_NODE): TRAFFIC_POINT 
			-- Location of `a_node'
		do

			if a_segments.first.start_node = a_node then
				Result := a_segments.first.polypoints.first
			else
				Result := a_segments.first.polypoints.last
			end
		end

invariant

	name_not_void: name /= Void
	name_not_empty: not name.is_empty
	stations_not_void: stations /= Void

end
