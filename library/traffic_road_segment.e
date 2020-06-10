note
	description: "Directed road connections that connect two stations"
	date: "$Date: 2006-03-27 19:42:12 +0200 (Mon, 27 Mar 2006) $"
	revision: "$Revision: 601 $"

class
	TRAFFIC_ROAD_SEGMENT

inherit

	TRAFFIC_SEGMENT
		redefine
			type,
			add_to_city,
			remove_from_city
		end

create
	make

feature {NONE} -- Creation

	make (a_origin, a_destination: TRAFFIC_NODE; a_type: TRAFFIC_TYPE_ROAD; an_id: INTEGER)
			-- Initialize `Current'.
		require
			a_origin_exists: a_origin /= Void
			a_destination_exists: a_destination /= Void
			a_type_exists: a_type /= Void
		do
			start_node := a_origin
			end_node := a_destination
			make_directed (start_node, end_node)
			type := a_type
			is_directed:=true
			create polypoints.make (0)
			polypoints.force_last (a_origin.station.location)
			polypoints.force_last (a_destination.station.location)
			id := an_id
		ensure
			origin_set: start_node = a_origin
			destination_set: end_node = a_destination
			type_set: type = a_type
			polypoints_exists: polypoints /= Void
			id_set: id = an_id
		end

feature -- Access

	weight_factor: REAL_64
			-- Factor with which the length of the connection is multiplied
		do
			Result := 10
		end

	hash_code: INTEGER
			-- Hash code value
		do
			Result := ([origin, destination, id]).hash_code
		end

	type: TRAFFIC_TYPE_ROAD
			-- Road type

	id: INTEGER
			-- Id of road

feature {TRAFFIC_ROAD} -- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all nodes to `a_city'.
		do
			a_city.graph.put_road (Current)
			is_in_city := True
			city := a_city
		ensure then
			graph_has: a_city.graph.has_edge (Current)
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			city.graph.prune_edge (Current)
			is_in_city := False
			city := Void
		end

feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- E.g. are all needed elements already inserted in the city?
		do
			Result := 	start_node.is_in_city and end_node.is_in_city and
						origin.is_in_city and destination.is_in_city
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `a_city'?
		do
			Result := True
		end

invariant

	id_set: id > 0
	type_exists: type /= Void

end
