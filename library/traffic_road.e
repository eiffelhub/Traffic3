note
	description: "Roads in the city (e.g. streets, lightrailroads, railroads)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_ROAD

inherit

	TRAFFIC_CITY_ITEM
		redefine
			add_to_city,
			remove_from_city
		end

create
	make, make_one_way

feature {NONE} -- Initialization

	make (a_conn1, a_conn2: TRAFFIC_ROAD_SEGMENT)
			-- Initialize a two way road with `a_conn1' and `a_conn2'.
		require
			a_conn1_exists: a_conn1 /= Void
			a_conn2_exists: a_conn2 /= Void
			same_type: a_conn1.type.is_equal (a_conn2.type)
			same_start: a_conn1.start_node = a_conn2.end_node
			same_end: a_conn1.end_node = a_conn2.start_node
			same_id: a_conn1.id = a_conn2.id
		do
			one_way := a_conn1
			other_way := a_conn2
			id := a_conn1.id
			is_one_way := False
			create changed_event
		ensure
			one_way_set: one_way = a_conn1
			other_way_set: other_way = a_conn2
			not_one_way_road: not is_one_way
			id_set: id = one_way.id
		end

	make_one_way (a_conn: TRAFFIC_ROAD_SEGMENT)
			-- Initialize a one way road with `a_conn'.
		require
			a_conn_exists: a_conn /= Void
		do
			one_way := a_conn
			is_one_way := True
			id := a_conn.id
			create changed_event
		ensure
			one_way_set: one_way = a_conn
			other_way_not_set: other_way = Void
			not_one_way_road: is_one_way
			id_set: id = one_way.id
		end

feature -- Access

	type: TRAFFIC_TYPE_ROAD
			-- Type of the road
		do
			Result := one_way.type
		ensure
			Result_set: Result = one_way.type
		end

	one_way: TRAFFIC_ROAD_SEGMENT
			-- Road segment into one direction

	other_way: TRAFFIC_ROAD_SEGMENT
			-- Road segment into other direction (may be Void if the way is a one way)

	id: INTEGER
			-- Id of the road

	get_connecting_segment(a_origin, a_destination: TRAFFIC_STATION): TRAFFIC_ROAD_SEGMENT
			-- returns the road segment connecting `a_origin' and `a_destination'
		require
			connected: connects(a_origin, a_destination)
		do
			if one_way.origin = a_origin then
				result:= one_way
			else
				result := other_way
			end
		ensure
			result.origin = a_origin and result.destination = a_destination
		end


feature {TRAFFIC_EVENT_CONTAINER}-- Basic operations

	add_to_city (a_city: TRAFFIC_CITY)
			-- Add `Current' and all nodes to `a_city'.
		do
			one_way.add_to_city (a_city)
			if not is_one_way then
				other_way.add_to_city (a_city)
			end
			is_in_city := True
			city := a_city
		end

	remove_from_city
			-- Remove all nodes from `city'.
		do
			one_way.remove_from_city
			if not is_one_way then
				other_way.remove_from_city
			end
			is_in_city := False
			city := Void
		end



feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- E.g. are all needed elements already inserted in the city?
		do
			Result := 	one_way.start_node.is_in_city and one_way.end_node.is_in_city and
						one_way.origin.is_in_city and one_way.destination.is_in_city
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
		local
			l: DS_ARRAYED_LIST [TRAFFIC_LINE_SEGMENT]
		do
			Result := True
			if is_in_city then
				l := one_way.origin.outgoing_line_connections
				from
					l.start
				until
					l.after or not Result
				loop
					if l.item_for_iteration.roads.has (Current.one_way) then
						Result := False
					end
					l.forth
				end
				if not is_one_way and Result then
					l := other_way.origin.outgoing_line_connections
					from
						l.start
					until
						l.after or not Result
					loop
						if l.item_for_iteration.roads.has (Current.other_way) then
							Result := False
						end
						l.forth
					end
				end
			end
		end

	is_one_way: BOOLEAN
			-- Is this a one way road?


	connects(a_origin, a_destination: TRAFFIC_STATION): BOOLEAN
			-- does this road connect `a_origin' and `a_destination?
		require
			a_origin_exists: a_origin /= void
			a_destination_exists: a_destination /= void
		do
			if one_way.origin = a_origin and one_way.destination = a_destination then
					result := true
			elseif other_way.origin = a_origin and other_way.destination = a_destination then
					result := true
			end
		end


invariant

	has_segments: is_one_way implies one_way /= Void and other_way = Void
	has_segments: not is_one_way implies one_way /= Void and other_way /= Void
	id_set: id > 0 and id = one_way.id

end
