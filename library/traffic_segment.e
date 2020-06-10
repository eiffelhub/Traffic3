note
	description: "Deferred segments for the graph"
	date: "$Date: 2006-03-27 19:42:12 +0200 (Mon, 27 Mar 2006) $"
	revision: "$Revision: 601 $"

deferred class
	TRAFFIC_SEGMENT

inherit
	LINKED_GRAPH_WEIGHTED_EDGE [TRAFFIC_NODE, REAL_64]
		rename
			make_directed as make_directed_old,
			make_undirected as make_undirected_old,
			internal_start_node as start_node,
			internal_end_node as end_node,
			make as make_old
		export {NONE}
			make_directed_old, make_undirected_old
		redefine
			out, is_equal, start_node, end_node
		end

	TRAFFIC_CITY_ITEM
		undefine
			out, is_equal
		end

feature {NONE} -- Initialization

	make_directed (a_start_node, a_end_node: like start_node)
		require
			nodes_not_void: a_start_node /= Void and a_end_node /= Void
		do
			start_node := a_start_node
			end_node := a_end_node
			is_directed := True
			create state.make
			create changed_event
		ensure
			nodes_not_void: start_node /= Void and
							end_node /= Void
			is_directed: is_directed
		end


feature -- Measure


	travel_time(speed: REAL_64):REAL_64
			-- calculates the travel time between 'origin' and 'destination'
			-- with a certain speed (km/h).Result is given in Minutes.
			local
				real_distance_m: REAL_64
				real_distance_km:REAL_64
				real_time: REAL_64
			do
				if length > 0 then
					real_distance_m:= length*(city.scale_factor)
					real_distance_km:= real_distance_m/1000
					real_time:=(real_distance_km/speed)*60
				else
					real_time:=0.0
				end

				Result:= real_time

			end

feature -- Element change

	set_state (a_state: TRAFFIC_SEGMENT_STATE)
			-- Change state to `a_state'.
		require
			a_state_exists: a_state /= Void
		do
			state := a_state
			changed_event.publish ([])
		ensure
			state_set: state = a_state
		end

	set_polypoints (a_polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT])
			-- Set polypoints to `a_polypoints'.
		require
			a_polypoints_exist: a_polypoints /= Void
		do
			polypoints.copy (a_polypoints)
			changed_event.publish ([])
		ensure
			polypoints_exists: polypoints /= Void
		end

	remove_polypoints
			-- Remove polypoints.
		do
			polypoints.wipe_out
			changed_event.publish ([])
		ensure
			polypoints_empty: polypoints.is_empty
		end

feature -- Access

	state: TRAFFIC_SEGMENT_STATE
			-- State of segment

	type: TRAFFIC_TYPE
			-- Type of the line segment

	origin: TRAFFIC_STATION
			-- Station of origin
		do
			Result := start_node.station
		end

	destination: TRAFFIC_STATION
			-- Station of destination
		do
			Result := end_node.station
		end

	polypoints: DS_ARRAYED_LIST [TRAFFIC_POINT]
			-- Location representation of the segment.

	length: REAL_64
			-- Length from start of polypoints to end.
			-- If no polypoints exists, distance between origin and destination.
		local
			i: INTEGER
		do
			if polypoints = Void or polypoints.count < 1 then
				Result := origin.location.distance (destination.location)
			else
				Result := 0.0
				from
					i := 1
				until
					i = polypoints.count
				loop
					Result := Result + polypoints.item (i).distance (polypoints.item (i + 1))
					i := i + 1
				end
			end
		end

feature -- Access

	weight_factor: REAL_64
			-- Factor with which the length of the segment is multiplied
		deferred
		ensure
			weight_factor_valid: Result > 0
		end

	start_node: TRAFFIC_NODE

	end_node: like start_node

feature -- Status report

	is_equal (other: like Current): BOOLEAN
			-- Is `other' attached to an object considered
			-- equal to current object?
		do
			-- Start and end node must be equal.
			Result := start_node.is_equal (other.start_node) and
					  end_node.is_equal (other.end_node)
		end

feature -- Output

	out: STRING
			-- Textual representation of the edge
		do
			Result := start_node.out
			if is_directed then
				Result.append (" -> ")
			else
				Result.append (" -- ")
			end
			Result.append (end_node.out)
		end

invariant

	polypoints_exist: polypoints /= Void
	nodes_exist: start_node /= Void and end_node /= Void
	is_directed: is_directed
	state_valid: state /= Void

end
