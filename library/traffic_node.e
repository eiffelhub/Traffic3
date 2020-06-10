note
	description: "Node in the graph (a node is an endpoint of a connection)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_NODE

inherit
	LINKED_GRAPH_NODE [TRAFFIC_NODE, REAL_64]
		rename
			referring_edge as referring_connection,
			put_edge as put_connection,
			edge_list as connection_list
		redefine
			hash_code,
			connection_list,
			referring_connection,
			put_connection
		end

	TRAFFIC_CITY_ITEM
		undefine
			is_equal,
			add_to_city,
			remove_from_city
		end

create
	make_with_station

feature {NONE} -- Initialization

	make_with_station (s: TRAFFIC_STATION; a_location: TRAFFIC_POINT)
			-- Initialize `Current'.
		require
			not_void: s /= Void
			location_not_void: a_location /= Void
		do
			create connection_list.make

			item := Current
			station := s
			location := a_location
			create connection_list.make
--			reset
--			if station.dummy_node /= Void then
--				station.add_node (Current)
--			end
			create changed_event
		ensure
			no_referrer: (referring_node = Void) and (referring_connection = Void)
			distance_positive: distance >= 0
			fresh: not processed
			station_set: station = s
			location_set: location = a_location
			no_neighbors: connection_list.is_empty
		end

feature -- Access

	station: TRAFFIC_STATION
			-- Station that it belongs to

	location: TRAFFIC_POINT
			-- Location of the node

	connection_list: TWO_WAY_CIRCULAR [TRAFFIC_SEGMENT]
			-- List of all segments that this node is an startpoint of

	hash_code: INTEGER
			-- Hash code value
		do
			Result := ([station, location]).hash_code
		end

feature -- Element change

	set_location (a_location: TRAFFIC_POINT)
			-- Set location to `a_location'.
		require
			location_exists: a_location /= Void
		do
			location := a_location
			changed_event.publish ([])
		ensure
			position_set: location = a_location
		end

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
		do
			Result := connection_list.is_empty
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
		do
			Result := True
		end

feature {TRAFFIC_STATION} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all nodes to `a_city'.
		local
			e: TRAFFIC_EXCHANGE_SEGMENT
			p: DS_ARRAYED_LIST [TRAFFIC_POINT]
		do
			a_city.graph.put_node (Current)
			is_in_city := True
			city := a_city
			-- Connect the stop to the dummy_node
			if Current /= station.dummy_node then
				create e.make (Current, station.dummy_node, create {TRAFFIC_TYPE_STREET}.make, a_city.graph.id_manager.next_free_index)
				create p.make (2)
				p.put_first (location)
				p.put_last (station.dummy_node.location)
				e.set_polypoints (p)
				e.add_to_city (a_city)
				create e.make (station.dummy_node, Current, create {TRAFFIC_TYPE_STREET}.make, a_city.graph.id_manager.next_free_index)
				create p.make (2)
				p.put_first (station.dummy_node.location)
				p.put_last (location)
				e.set_polypoints (p)
				e.add_to_city (a_city)
			end
		ensure then
			graph_has: a_city.graph.has_node (Current)
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			city.graph.prune_node (Current)
			is_in_city := False
			city := Void
		end

feature {TRAFFIC_GRAPH} -- Element change

	put_connection (a_connection: like referring_connection)
			-- Insert `a_connection'.
		do
			connection_list.extend (a_connection)
			changed_event.publish ([])
		end

feature {NONE} -- Implementation

	referring_connection: TRAFFIC_SEGMENT
			-- Edge where we came from

invariant

	station_not_void: station /= Void
	location_not_void: location /= Void
	item_is_self: item = Current
	connection_list_exists: connection_list /= Void

end
