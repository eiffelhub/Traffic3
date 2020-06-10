note
	description: "Traffic graph containing nodes and connections"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_GRAPH

inherit

	LINKED_WEIGHTED_GRAPH [TRAFFIC_NODE, REAL_64_REF]
		rename
			put_edge as connect_nodes
		redefine
			current_node,
			edge_item,
			node_from_item,
			adopt_edge,
			has_edge,
			edge_occurences,
			put_node,
			connect_nodes,
			prune_node,
			prune_edge_impl,
			prune_edge,
			find_shortest_path
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			default_size: INTEGER
		do
			default_size := 100
			make_multi_graph
			shortest_path_mode := normal_distance
			create id_manager
		end

feature {TRAFFIC_CITY_ITEM} -- Insertion

	connect_nodes (a_start_node, a_end_node: like item; a_label: REAL_64; a_weight: REAL_64)
			-- Redefined to record weight.
		local
			r: TRAFFIC_ROAD_SEGMENT
		do
			create r.make (a_start_node, a_end_node, create {TRAFFIC_TYPE_STREET}.make, id_manager.next_free_index)
			a_start_node.put_connection (r)
			internal_edges.extend (r)
			id_manager.take (r.id)
			total_weight := total_weight + r.length
		end

	put_road (a_road: TRAFFIC_ROAD_SEGMENT)
			-- Insert `a_road' into the graph.
		require
			a_road_exists: a_road /= Void
			nodes_exist: has_node (a_road.start_node) and has_node (a_road.end_node)
		do
			a_road.start_node.put_connection (a_road)
			internal_edges.extend (a_road)
			id_manager.take (a_road.id)
			total_weight := total_weight + a_road.length
			if not a_road.is_directed then
				a_road.end_node.put_connection (a_road)
			end
		end

	put_line_segment (a_segment: TRAFFIC_LINE_SEGMENT)
			-- Insert `a_segment' into the graph.
		require
			a_segment_exists: a_segment /= Void
			nodes_exist: has_node (a_segment.start_node) and has_node (a_segment.end_node)
		do
			a_segment.start_node.put_connection (a_segment)
			internal_edges.extend (a_segment)
			total_weight := total_weight + a_segment.length
			if not a_segment.is_directed then
				a_segment.end_node.put_connection (a_segment)
			end
		end

	put_segment (a_segment: TRAFFIC_SEGMENT)
			-- Insert `a_segment' into the graph.
		require
			a_segment_exists: a_segment /= Void
			nodes_exist: has_node (a_segment.start_node) and has_node (a_segment.end_node)
		local
			r: TRAFFIC_ROAD_SEGMENT
			l: TRAFFIC_LINE_SEGMENT
		do
			r ?= a_segment
			l ?= a_segment
			if r /= Void then
				put_road (r)
			elseif l /= Void then
				put_line_segment (l)
			else
				a_segment.start_node.put_connection (a_segment)
				internal_edges.extend (a_segment)
				total_weight := total_weight + a_segment.length
				if not a_segment.is_directed then
					a_segment.end_node.put_connection (a_segment)
				end
			end
		end

	put_node (a_node: like item)
			-- Insert a new node in the graph if it is not already present.
			-- The cursor is not moved.
		local
			index: INTEGER
		do
			if not node_list.has (a_node) then
				-- Compute item index of new element.
				if not inactive_nodes.is_empty then
					inactive_nodes.start
					index := inactive_nodes.item
					inactive_nodes.prune (index)
				else
					index := node_count + 1
				end

				-- Create new node object and put it
				-- into the list at appropriate position.
				node_list.force (a_node, index)
				index_of_element.force (index, a_node)
				node_count := node_count + 1
			else
				io.put_string ("not inserted%N")
			end
		end

feature -- Removal

	prune_edge (a_edge: like edge_item)
			-- Remove `a_edge' from the graph.
			-- (from LINKED_GRAPH)
		local
			linked_edge: like edge_item
			start_node, end_node: like current_node
		do
			prune_edge_impl (a_edge)
			if is_symmetric_graph then
				linked_edge ?= a_edge
				if linked_edge /= Void then
					start_node := linked_edge.start_node
					end_node := linked_edge.end_node
				else
					start_node := linked_node_from_item (a_edge.start_node)
					end_node := linked_node_from_item (a_edge.end_node)
				end
				a_edge.flip
				prune_edge_impl (a_edge)
				a_edge.flip
			end
		end

	prune_node (a_item: like item)
			-- Remove `a_item' and all of its incident edges from the graph.
			-- `off' will be set when `item' is removed.
			-- The cursor will turn right if `target' is removed.
		local
			index: INTEGER
			edge: like edge_item
			dangling_edges: LINEAR [like edge_item]
		do
			-- Graph becomes `off' when current node is removed.
			if (not off) and equal (item, a_item) then
				current_node := Void
			elseif (not off) and equal (target, a_item) then
				if out_degree > 1 then
					-- Turn right if `target' is removed.
					right
				else
					exhausted := True
				end
			end

			-- Get index of `a_item'.
			index := index_of_element.item (a_item)

			if index > 0 then
				-- Node found: remove `a_item' from node list.
				node_list.put (Void, index)
				inactive_nodes.extend (index)
				index_of_element.remove (a_item)

				-- Remove all incident edges of `a_item'.
				from
					dangling_edges := internal_edges.linear_representation
					dangling_edges.start
				until
					dangling_edges.after
				loop
					edge := dangling_edges.item
					if edge.start_node.is_equal (a_item) then
						-- Remove edge starting in `a_item'.
						total_weight := total_weight - edge.length
						internal_edges.prune (edge)
					elseif edge.end_node.is_equal (a_item) then
						-- Remove edge ending in `a_item'.
						prune_edge_impl (edge)
					else
						dangling_edges.forth
					end
				end

				-- Adjust node counter.
				node_count := node_count - 1
			end
		end

feature -- Access

	shortest_path_mode: INTEGER
			-- Mode to calculate shortest paths

	id_manager: TRAFFIC_ID_MANAGER
			-- Manager for road ids

	current_node: TRAFFIC_NODE
			-- Value of the currently focused node

	edge_item: TRAFFIC_SEGMENT
			-- Current edge
		do
			if not current_node.connection_list.off then
				Result ?= current_node.connection_list.item
			else
				Result := Void
			end
		end

feature -- Basic operations

	find_shortest_path (a_start_node, a_end_node: like item)
			-- Enable the weight functions first.
		do
			enable_user_defined_weight_function (agent calculate_weight (?))
			Precursor (a_start_node, a_end_node)
		end

feature -- Constants

	normal_distance: INTEGER = 0
			-- Use normal path calculation

	minimal_switches: INTEGER = 1
			-- Use minimal switches path calculation

feature -- Status Setting

	set_shortest_path_mode (a_mode: INTEGER)
			-- Set path mode to `a_mode'.
		require
			a_mode_valid: a_mode = normal_distance or a_mode = minimal_switches
		do
			shortest_path_mode := a_mode
		ensure
			path_mode_set: shortest_path_mode = a_mode
		end

feature -- Status Report

	edge_occurences (a_edge: like edge_item): INTEGER_32
			-- Number of times `a_edge' appears in the graph (object equality)
		local
			c: like cursor
		do
			if not off then
				c := cursor
			end
			search (a_edge.start_node)
			if off then
				Result := 0
			else
				from
					start
				until
					exhausted
				loop
					if edge_item.is_equal (a_edge) then
						Result := Result + 1
					end
					left
				end
			end
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

	has_edge (a_edge: like edge_item): BOOLEAN
			-- Is `a_edge' part of the graph?
		local
			linked_graph_edge: like edge_item
			node: like current_node
			index: INTEGER_32
		do
			linked_graph_edge ?= a_edge
			if linked_graph_edge /= Void then
				node := linked_graph_edge.start_node
			else
				node := linked_node_from_item (a_edge.start_node)
			end
			from
				index := node.connection_list.index
				node.connection_list.start
			until
				node.connection_list.exhausted or else a_edge.is_equal (node.connection_list.item)
			loop
				node.connection_list.forth
			end
			Result := not node.connection_list.exhausted
			node.connection_list.go_i_th (index)
		end

feature {NONE} -- Implementation

	adopt_edge (a_edge: like edge_item)
			-- Put `a_edge' into current graph.
		do
			connect_nodes (a_edge.start_node, a_edge.end_node, a_edge.label, a_edge.weight)
		end

	weight_function: FUNCTION [ANY, TUPLE [TRAFFIC_SEGMENT], REAL_64]
			-- Weight function for edges, if Void, no weight function is used.

	prune_edge_impl (a_edge: like edge_item)
			-- Redefined to subtract the length of the segment from the total.
		do
			total_weight := total_weight - a_edge.length
			Precursor (a_edge)
		end

	calculate_weight (a_edge: TRAFFIC_SEGMENT): REAL_64
			-- Calculate the edge based on the current status.
			-- This is only used for "dummy" segments.
		local
			e: TRAFFIC_EXCHANGE_SEGMENT
		do
			inspect shortest_path_mode
			when normal_distance then
				Result := a_edge.length * a_edge.weight_factor
			when minimal_switches then
				e ?= a_edge
				if e /= Void then
					Result := average_weight
				else
					Result := a_edge.length * a_edge.weight_factor
				end
			else
				(create {EXCEPTIONS}).raise ("Unknown path mode in TRAFFIC_GRAPH")
			end
		end

	total_weight: REAL_64
		-- Total length of all TRAFFIC_SEGMENTSs added.
		-- Usually less then the total weight of the edges because
		-- the "dummy" segments have a higher weight than their length.

	average_weight: REAL_64
			-- Average weight of an edge used for "dummy" segments
			-- between nodes of the same station.
		do
			Result := total_weight / internal_edges.count
		end

	node_from_item (a_item: like item): NODE [like item, REAL_64_REF]
			-- Node object from item value
			-- (from GRAPH)
		local
			index: INTEGER_32
		do
			index := index_of_element.item (a_item)
			Result := annotated_nodes.item (index)
		end

end
