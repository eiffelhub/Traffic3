note
	description: "[
		Directed graphs without commitment to a particular representation.
		Simple graphs, multigraphs, directed graphs and symmetric graphs
		are supported.
		]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"


deferred class
	GRAPH [G -> HASHABLE, reference L]

inherit
	FINITE [G]
		rename
			count as node_count,
			has as has_node
		redefine
			changeable_comparison_criterion
		end

	CURSOR_STRUCTURE [G]
		rename
			has as has_node,
			put as put_node,
			prune as prune_node,
			remove as remove_node
		redefine
			changeable_comparison_criterion
		end

	SET [G]
		rename
			count as node_count,
			has as has_node,
			put as put_node,
			prune as prune_node
		redefine
			changeable_comparison_criterion
		end

	WALKABLE [G] -- A graph is a walkable structure
		rename
			has as has_node,
			is_first as is_first_edge,
			link_count as out_degree,
			turn_to as turn_to_target
		redefine
			item,
			changeable_comparison_criterion
		end

feature {NONE} -- Initialization

	make_empty_graph
			-- Make a non-specific empty graph.
		deferred
		ensure
			object_comparison: object_comparison
			is_empty: is_empty
			no_edges: edges.is_empty
			off: off
			item_index_not_void: index_of_element /= Void
			history_stack_not_void: history_stack /= Void
			history_stack_empty: history_stack.is_empty
		end

	make_simple_graph
			-- Make a simple graph.
		do
			make_empty_graph
			set_is_simple_graph (True)
			set_is_symmetric_graph (False)
			object_comparison := True
		ensure
			is_simple_graph: is_simple_graph
			not_symmetric_graph: not is_symmetric_graph
			empty_graph: (node_count = 0) and (edge_count = 0)
		end

	make_symmetric_graph
			-- Make a simple symmetric graph.
		do
			make_empty_graph
			set_is_simple_graph (True)
			set_is_symmetric_graph (True)
			object_comparison := True
		ensure
			is_simple_graph: is_simple_graph
			is_symmetric_graph: is_symmetric_graph
			empty_graph: (node_count = 0) and (edge_count = 0)
		end

	make_multi_graph
			-- Make a multigraph.
		do
			make_empty_graph
			set_is_simple_graph (False)
			set_is_symmetric_graph (False)
			object_comparison := True
		ensure
			is_multi_graph: is_multi_graph
			not_symmetric_graph: not is_symmetric_graph
			empty_graph: (node_count = 0) and (edge_count = 0)
		end

	make_symmetric_multi_graph
			-- Make a symmetric multigraph.
		do
			make_empty_graph
			set_is_simple_graph (False)
			set_is_symmetric_graph (True)
			object_comparison := True
		ensure
			is_multi_graph: is_multi_graph
			is_symmetric_graph: is_symmetric_graph
			empty_graph: (node_count = 0) and (edge_count = 0)
		end

feature -- Access

	last_inserted_edge: EDGE [G, L]
			-- Edge that was created with the last put_..._edge command

	cursor: GRAPH_CURSOR [G, L]
			-- Current cursor position
		do
			if not off then
				create Result.make (item, edge_item)
			else
				Result := Void
			end
		ensure then
			void_when_off: off = (Result = Void)
		end

	target: like item
			-- Item at the target of the current edge
		do
			Result := edge_item.end_node
		end

	target_cursor: like cursor
			-- Cursor position for `target'
		do
			if off then
				Result := Void
			else
				forth
				create Result.make (item, edge_item)
				back
			end
		ensure then
			void_when_off: off = (Result = Void)
		end

	nodes,vertices: SET [like item]
			-- All nodes of the graph
		deferred
		ensure
			result_not_void: Result /= Void
		end

	edges: LIST [like edge_item]
			-- All edges of the graph
		deferred
		ensure
			edges_not_void: Result /= Void
		end

	edge_item: EDGE [like item,L]
			-- Current edge
		require
			not_off: not off
		deferred
		end

	incident_edges: LIST [like edge_item]
			-- All incident edges of `item'
		require
			not_off: not off
		deferred
		ensure
			result_not_void: Result /= Void
			degree_match: Result.count = out_degree
		end

	incident_edge_labels: LIST [L]
			-- Labels of all incident edges of `item'
		require
			not_off: not off
		deferred
		ensure
			result_not_void: Result /= Void
			degree_match: Result.count = out_degree
		end

	neighbors: SET [like item]
			-- All neighbor nodes of `item'
		require
			not_off: not off
		local
			c: like cursor
		do
			-- Backup cursor
			c := cursor

			create {LINKED_SET [like item]}Result.make
			from
				start
			until
				exhausted
			loop
				Result.put (target)
				left
			end

			-- Restore cursor.
			go_to (c)
		ensure
			result_not_void: Result /= Void
			simple_graph_neighbors: is_simple_graph implies Result.count = out_degree
			multi_graph_neighbors: is_multi_graph implies Result.count <= out_degree
		end

	edge_from_values (a_start_node, a_end_node: like item; a_label: L): EDGE [like item,L]
			-- Edge that matches `a_start_node', `a_end_node' and `a_label'.
			-- Result is Void if there is no matching edge in the graph.
			-- The cursor is not moved.
		deferred
		ensure
			cursor_not_moved: equal (cursor, old cursor)
		end

	path: LIST [like edge_item]
			-- Path that has been found with `find_path'
		require
			path_found: path_found
		do
			Result := path_impl
		ensure
			path_not_void: Result /= Void
		end


	linear_representation: LINEAR [like item]
			-- Linear representation of the node set
		do
			Result := nodes.linear_representation
		end

	node_identity: HASHABLE
			-- Object that identifies the current item
		require
			not_off: not off
		deferred
		end

	conflicting_edges: LINKED_LIST [like edge_item]
			-- Edges that could not be unified with current graph
			-- using the `merge_with' command.
		require
			merge_failed: not merge_succeeded
		do
			Result := conflicting_edges_impl
		ensure
			result_not_void: Result /= Void
		end

feature -- Measurement

	node_count: INTEGER
			-- Number of nodes in the graph
		do
			Result := nodes.count
		end

	edge_count: INTEGER
			-- Number of edges in the graph
		do
			Result := edges.count
		end

	in_degree: INTEGER
			-- Number of incoming edges of `item'
		require
			not_off: not off
		deferred
		ensure
			valid_degree: Result >= 0
		end

	out_degree: INTEGER
			-- Number of outgoing edges of `item'
		local
			edge: like edge_item
		do
			-- Make backup of `target'.
			edge := edge_item

			-- Count all incident edges of `item'
			from
				start
				Result := 0
			until
				exhausted
			loop
				Result := Result + 1
				left
			end

			-- Restore `target'.
			turn_to_edge (edge)
		ensure then
			same_direction: equal (edge_item, old edge_item)
			valid_degree: Result >= 0
		end

	components: INTEGER
			-- Number of (weakly) connected components of the graph
		local
			edge: like edge_item
			node_list: like linear_representation
			edge_list: LINEAR [like edge_item]
			set_1, set_2: INTEGER
			uf: UNION_FIND_STRUCTURE [like item]
		do
			node_list := linear_representation
			edge_list := edges.linear_representation

			-- Initialize union-find data structure.
			create uf.make (node_count)
			from
				node_list.start
			until
				node_list.after
			loop
				uf.put (node_list.item)
				node_list.forth
			end

			-- Run the union-find algorithm over all edges of the graph.
			from
				edge_list.start
			until
				edge_list.after
			loop
				edge := edge_list.item
				set_1 := uf.find (edge.start_node)
				set_2 := uf.find (edge.end_node)
				if set_1 /= set_2 then
					uf.union (set_1, set_2)
				end
				edge_list.forth
			end
			Result := uf.set_count
		end

feature -- Status report

	changeable_comparison_criterion: BOOLEAN
			-- May `object_comparison' be changed?
		do
			Result := False
		end

	has_multi_graph_support: BOOLEAN
			-- Are multigraphs supported by the current implementation?
		deferred
		end

	has_node (a_item: like item): BOOLEAN
			-- Is `a_item' part of the node set?
		do
			-- Is there an item index for `a_item'?
			Result := index_of_element.has (a_item)
		end

	has_edge_between (a_start_node, a_end_node: like item): BOOLEAN
			-- Are `a_start_node' and `a_end_node' directly connected?
			-- Note: Edges are directed.
		require
			valid_nodes: has_node (a_start_node) and has_node (a_end_node)
		deferred
		end

	has_edge (a_edge: EDGE [like item, L]): BOOLEAN
			-- Is `a_edge' part of the graph?
		require
			edge_not_void: a_edge /= Void
			valid_nodes: has_node (a_edge.start_node) and has_node (a_edge.end_node)
		do
			Result := edges.has (a_edge)
		end

	has_links: BOOLEAN
			-- Does `item' have any outgoing edges?
		do
			Result := out_degree > 0
		end

	has_previous: BOOLEAN
			-- Is there another node in the traversal history?
			-- Must be True in order to use the `back' command.
		do
			if history_stack.is_empty then
				Result := False
			else
				Result := has_node (history_stack.item.current_node)
			end
		end

	occurrences (v: like item): INTEGER
			-- Number of times `v' appears in the graph (object equality)
		do
			if has_node (v) then
				Result := 1
			else
				Result := 0
			end
		end

	edge_occurences (a_edge: EDGE [like item, L]): INTEGER
			-- Number of times `a_edge' appears in the graph (object equality)
		require
			edge_not_void: a_edge /= Void
		local
			c: like cursor
		do
			-- Make backup of cursor if necessary.
			if not off then
				c := cursor
			end

			search (a_edge.start_node)
			if off then
				-- Edge is not part of the graph.
				Result := 0
			else
				-- Iterate over all outgoing edges to find matches.
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

			-- Restore cursor.
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

	is_reachable (other_item: like item): BOOLEAN
			-- Is `other_item' directly or indirectly reachable from `item'?
			-- Edge direction is taken into account.
			-- The cursor is not moved.
		require
			not_off: not off
			node_exists: has_node (other_item)
		do
			find_path (item, other_item)
			Result := path_found
		ensure
			cursor_not_moved: equal (cursor, old cursor)
		end

	is_connected: BOOLEAN
			-- Is the graph (weakly) connected?
		do
			Result := components = 1
		end

	path_found: BOOLEAN
			-- Has a path been found in `find_path'?
		deferred
		end

	has_cycles: BOOLEAN 
			-- Does the graph contain cyclic (directed) paths?
		local
			topo_sorter: TOPOLOGICAL_SORTER [like item]
			el: LINEAR [like edge_item]
			e: like edge_item
		do
			-- Perform topological sort to find cycles in the graph.
			create topo_sorter.make
			from
				el := edges.linear_representation
				el.start
			until
				el.after
			loop
				e := el.item
				topo_sorter.record_constraint (e.start_node, e.end_node)
				el.forth
			end
			topo_sorter.process

			Result := topo_sorter.cycle_found
		end

	is_dag: BOOLEAN
			-- Is the graph a DAG? (directed acyclic graph)
		do
			-- DAG definition: connected graph without any cycles.
			Result := is_connected and not has_cycles
		end

	is_eulerian: BOOLEAN
			-- Can the whole graph be drawn with a single closed line without lifting the pencil?
		local
			node_list: like linear_representation
			c: like cursor
		do
			-- Definition: A directed graph is Eularian iff
			-- it is connected and the in-degree and out-degree is equal for each node.

			if is_symmetric_graph then
				-- For symmetric graphs, the in- and out-degree is equal by definition.
				Result := is_connected
			else
				-- Backup cursor if necessary.
				if not off then
					c := cursor
				end
				Result := is_connected

				-- Check degrees for non-symmetric graphs.
				node_list := linear_representation
				from
					node_list.start
				until
					not Result or node_list.after
				loop
					search (node_list.item)
					Result := Result and (in_degree = out_degree)
					node_list.forth
				end

				-- Restore cursor.
				if c /= Void then
					go_to (c)
				else
					invalidate_cursor
				end
			end
		ensure
			cyclic_tour: Result implies has_cycles
			cursor_not_moved: equal (cursor, old cursor)
		end

	is_simple_graph: BOOLEAN
			-- Is the graph a simple graph?
			-- (i.e. at most one edge between two nodes)
		deferred
		end

	is_symmetric_graph: BOOLEAN
			-- Is the graph symmetric?
		deferred
		end

	is_multi_graph: BOOLEAN
			-- Is the graph a multigraph?
		do
			Result := not is_simple_graph
		end

	merge_succeeded: BOOLEAN
			-- Was the invocation of `merge_with' successful?
		deferred
		end

	reducible_multigraph: BOOLEAN
			-- Is the current multigraph also a simple graph?
			-- Required for command `convert_to_simple_graph'.
			-- Warning: This query might be quite inefficient for large graphs.
		require
			multigraph: is_multi_graph
		local
			lin: like linear_representation
			c: like cursor
			neighbrs: LINKED_SET [like item]
			out_deg: INTEGER
		do
			-- Backup cursor if necessary.
			if not off then
				c := cursor
			end

			-- The graph is a simple graph if the number of incident edges
			-- and the number of neighbor nodes are equal for each node.
			from
				Result := True
				lin := linear_representation
				lin.start
				create neighbrs.make
			until
				lin.after
			loop
				search (lin.item)
				from
					start
					neighbrs.wipe_out
					out_deg := 0
				until
					exhausted
				loop
					neighbrs.put (target)
					out_deg := out_deg + 1
					left
				end
				Result := Result and (neighbrs.count = out_deg)
				lin.forth
			end

			-- Restore cursor.
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

	readable: BOOLEAN
			-- Is there a current item that may be read?
		do
			Result := not off
		end

	extendible: BOOLEAN = True

	writable: BOOLEAN
			-- Is there a current item that may be modified?
		do
			Result := False
		end

	prunable: BOOLEAN
			-- May nodes be removed?
		do
			Result := not is_empty
		end

	valid_cursor (c: CURSOR): BOOLEAN
			-- Can the cursor be moved to position `c'?
		local
			cur, graph_cursor: like cursor
			edge: like edge_item
		do
			graph_cursor ?= c
			-- The focused node must be part of the graph in order to be valid.
			if (graph_cursor = Void) or else (not has_node (graph_cursor.current_node)) then
				Result := False
			else
				edge := graph_cursor.edge_item
				if edge /= Void then
					-- The focused edge must also be part of the graph.
					Result := has_node (edge.end_node) and then has_edge (edge)
				else
					cur := cursor

					-- A void edge is only allowed when there are no outgoing edges.
					search (graph_cursor.current_node)
					Result := not has_links

					-- Restore previous cursor position (if any).
					if cur /= Void then
						go_to (cur)
					else
						invalidate_cursor
					end
				end
			end
		end


feature -- Cursor movement

	start
			-- Turn to the first link.
		deferred
		end

	left
			-- Turn one edge to the left.
		deferred
		end

	right
			-- Turn one edge to the right.
		deferred
		end

	back
			-- Walk back to the previous node.
			-- Turn to the same edge as before (if possible).
			-- Otherwise, `exhausted' is set.
		do
			go_to (history_stack.item)
			history_stack.remove
		ensure then
			focused_edge_restored: not exhausted implies target.is_equal (old item)
		end

	forth
			-- Walk along the currently focused edge.
		do
			history_stack.put (cursor)
			go_to (target_cursor)
		end

	go_to (c: like cursor)
			-- Move cursor to position `c' and turn to the according edge.
			-- `exhausted' is set if that edge cannot be focused.
		do
			search (c.current_node)
			turn_to_edge (c.edge_item)
		ensure then
			equal_items: item.is_equal (c.current_node)
		end

	search (a_item: like item)
			-- Move to `a_item'. If no such position exists, `off' will be true.
		deferred
		ensure then
			off_iff_not_found: not has_node (a_item) = off
		end

	turn_to_edge (a_edge: EDGE [like item, L])
			-- Set `edge_item' to `a_edge' if possible.
			-- Otherwise, `exhausted' will be set.
		require
			not_off: not off
		do
			-- Reference equality has precedence over object equality.
			from
				start
			until
				exhausted or else edge_item = a_edge
			loop
				left
			end

			-- If reference equality fails, try again with object equality.
			if edge_item /= a_edge then
				from
					start
				until
					exhausted or else equal (edge_item, a_edge)
				loop
					left
				end
			end
		ensure
			edge_not_found: (a_edge /= Void and then not has_edge (a_edge)) implies exhausted
			edge_found: not exhausted implies edge_item.is_equal (a_edge)
		end

feature -- Element change

	put_node (a_item: like item)
			-- Insert a new node in the graph if it is not already present.
			-- The cursor is not moved.
		deferred
		ensure then
			node_present: has_node (a_item)
			index_of_element.has (a_item)
			cursor_not_moved: equal (cursor, old cursor)
		end

	put_edge (a_start_node, a_end_node: like item; a_label: L)
			-- Create an edge between `a_start_node' and `a_end_node'
			-- and set its label to `a_label'.
			-- For symmetric graphs, another edge is inserted in the opposite direction.
			-- The cursor is not moved.
		require
			nodes_exist: has_node (a_start_node) and has_node (a_end_node)
			simple_graph: is_simple_graph implies not has_edge_between (a_start_node, a_end_node)
			-- TO BE IMPROVED!!
		deferred
		ensure
			simple_graph_criterion: is_simple_graph implies has_edge_between (a_start_node, a_end_node)
			symmetric_graph_criterion: is_symmetric_graph implies has_edge_between (a_start_node, a_end_node) and
																  has_edge_between (a_end_node, a_start_node)
			simple_edge_count: is_simple_graph implies edge_count = old edge_count + 1
			symmetric_edge_count: is_symmetric_graph implies edge_count = old edge_count + 2
		end

	put_unlabeled_edge (a_start_node, a_end_node: like item)
			-- Create an edge between `a_start_node' and `a_end_node'.
			-- For symmetric graphs, another edge is inserted in the opposite direction.
			-- The cursor is not moved.
		require
			nodes_exist: has_node (a_start_node) and has_node (a_end_node)
			-- TO BE IMPROVED!!!
		do
			put_edge (a_start_node, a_end_node, Void)
		ensure
			simple_graph_criterion: is_simple_graph implies has_edge_between (a_start_node, a_end_node)
			symmetric_graph_criterion: is_symmetric_graph implies has_edge_between (a_start_node, a_end_node) and
																  has_edge_between (a_end_node, a_start_node)
			simple_edge_count: is_simple_graph implies edge_count = old edge_count + 1
			symmetric_edge_count: is_symmetric_graph implies edge_count = old edge_count + 2
			cursor_not_moved: equal (cursor, old cursor)
		end

feature -- Removal

	prune_node (a_item: like item)
			-- Remove `a_item' and all of its incident edges from the graph.
			-- `off' will be set when `item' is removed.
			-- The cursor will turn right if `target' is removed.
		deferred
		ensure then
--| FIXME	-- off_when_item_removed: (not old off) and then equal (a_item, old item) implies off
--| FIXME	-- Above contract seems correct, but produces contract violation
--| FIXME	-- when `off' is true before routine invocation.
			node_removed: not has_node (a_item)
		end

	prune_edge_between (a_start_node, a_end_node: like item)
			-- Remove the edge connecting `a_start_node' and `a_end_node'.
			-- This operation is only permitted on simple graphs because of ambiguity.
			-- The cursor will turn right if `edge_item' is removed.
		require
			simple_graph: is_simple_graph
			nodes_exist: has_node (a_start_node) and has_node (a_end_node)
			edge_exists: has_edge_between (a_start_node, a_end_node)
		deferred
		ensure
			nodes_exist: has_node (a_start_node) and has_node (a_end_node)
			edge_removed: not has_edge_between (a_start_node, a_end_node)
		end

	prune_edge (a_edge: EDGE [like item, L])
			-- Remove `a_edge' from the graph.
			-- The cursor will turn right if `current_egde' is removed.
		require
			edge_not_void: a_edge /= Void
			edge_exists: has_edge (a_edge)
		deferred
		ensure
			simple_edge_removed: not is_symmetric_graph implies edge_count = old edge_count - 1
			symmetric_edge_removed: is_symmetric_graph implies edge_count = old edge_count - 2
			exhausted_after_last_edge: not off and then (equal (a_edge, edge_item) and out_degree = 0) implies exhausted
		end

	remove_node
			-- Remove the current node and all its incident edges from the graph.
			-- `off' will be set.
		do
			prune_node (item)
		ensure then
			off
		end

	remove_edge
			-- Remove the current edge from the graph. The end nodes are not removed.
			-- The cursor will turn right.
		do
			prune_edge (edge_item)
		ensure
			exhausted_after_last_edge: (not off) and then (out_degree = 0) implies exhausted
		end

	wipe_out
			-- Remove all nodes and edges from the graph.
		do
			if is_simple_graph then
				if is_symmetric_graph then
					make_symmetric_graph
				else
					make_simple_graph
				end
			else
				if is_symmetric_graph then
					make_symmetric_multi_graph
				else
					make_multi_graph
				end
			end
		ensure then
			no_edges: edge_count = 0
			off: off
		end

feature -- Resizing

feature -- Transformation

feature -- Conversion

	convert_to_multi_graph
			-- Convert the current simple graph to a multigraph.
		require
			simple_graph: is_simple_graph
			supported: has_multi_graph_support
		do
			set_is_simple_graph (False)
		ensure
			multi_graph: is_multi_graph
		end

	convert_to_simple_graph
			-- Convert the current multigraph to a simple graph.
		require
			multigraph: is_multi_graph
			only_simple_edges: reducible_multigraph
		do
			set_is_simple_graph (True)
		ensure
			simple_graph: is_simple_graph
		end

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	find_path (a_start_node, a_end_node: like item)
			-- Find path from `a_start_node' to `a_end_node'.
			-- On success, `path_found' is set and the path is available in `path'.
		require
			nodes_not_void: (a_start_node /= Void) and (a_end_node /= Void)
			nodes_in_graph: has_node (a_start_node) and has_node (a_end_node)
		local
			c: like cursor
			focused_item, it: like item
			focused_node, target_node, node: NODE [like item, L]
			el: like incident_edges
			e: like edge_item
			dist: REAL_64
		do
			-- Shortest path algorithm used for both weighted and unweighted graphs.
			-- In unweighted graphs, we look for the path with the minimum amount of edges.

			-- Make backup of old cursor position if necessary.
			if not off then
				c := cursor
			end

			-- Initialize data structure to keep track of half- or fully processed nodes.
			prepare_path_finding
			target_node := node_from_item (a_end_node)

			-- Main algorithm: Explore reachable node set with breadth-first strategy.
			-- Continue exploring from node with minimal distance from start node.
			-- If a node is reached faster than before, update its distance
			-- and store the edge where we came from.
			from
				-- Initialize start node.
				node := node_from_item (a_start_node)
				node.set_referrer (Void, Void, 0)
				border_nodes.put (node)
			until
				border_nodes.is_empty or target_node.processed
			loop
				-- Get node with minimal distance
				node := border_nodes.item
				border_nodes.remove
				node.set_processed

				-- Put all items reachable from current node into `border_nodes'.
				search (node.item)
				from
					el := incident_edges
					el.start
				until
					el.after
				loop
					focused_item := opposite_node (el.item, node.item)
					focused_node := node_from_item (focused_item)
					dist := node.distance + edge_length (el.item)
					if dist < focused_node.distance then
						-- Focused node has been reached faster than ever before:
						-- Update its distance and keep track of the referring edge.
						focused_node.set_referrer (node, el.item, dist)
						border_nodes.put (focused_node)
					end
					el.forth
				end
			end

			set_path_found (target_node.processed)

			if path_found then
				-- We have found a path connecting `a_start_node' and `a_end_node'.
				-- Follow the referrer edges to build up the path
				-- (traverse path in reverse order until the start node is reached).
				from
					create path_impl.make
					node := target_node
					it := a_end_node
				until
					node.referring_edge = Void
				loop
					e := node.referring_edge

					-- Flip edges if necessary to make the output meaningful.
					if not it.is_equal (e.end_node) then
						-- This can only happen in case of undirected edges.
						e.flip
					end

					path_impl.put_front (e)
					node := node.referring_node
					it := e.start_node
				end
			end

			-- Free memory used for annotated nodes.
			annotated_nodes := Void

			-- Restore old cursor position.
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

	reset_path
			-- Reset result of `find_path' to free memory.
		do
			path_impl := Void
			set_path_found (False)
		ensure
			no_path: (path_found = False) and (path = Void)
		end

	merge_with (other: like Current)
			-- Create the union of the current graph with `other'.
			-- If `Current' is a simple graph, it is converted to multigraph if necessary.
			-- Behavior (nodes): The node sets are unified by regular set union.
			-- Behavior (edges): Identical edges in `Current' and `other' appear only once
			-- in the resulting graph (=union of the edge sets).
			-- Notice: On success, the flag `merge_succeeded' is set.
			-- If a conversion to multigraph is needed, but the current implementation
			-- has no multigraph support, the flag `merge_succeeded' is set to "False".
			-- All edges which could not be adopted are listed in `conflicting_edges'.
		require
			other_not_void: other /= Void
		local
			was_simple_graph: BOOLEAN
		do
			-- Assume merge operation will succeed.
			set_merge_succeeded (True)

			-- Put all nodes of `other' into current graph.
			merge_nodes (other)

			-- Convert current graph to a multigraph if necessary
			-- to avoid errors with the "put_edge" command.
			if is_simple_graph and has_multi_graph_support then
				was_simple_graph := True
				convert_to_multi_graph
			end

			-- Put all edges of `other' into current graph.
			if is_multi_graph then
				merge_edges (other)
			else
				simple_merge_edges (other)
			end

			-- Convert the graph back to a simple graph if possible.
			if was_simple_graph and is_multi_graph and reducible_multigraph then
				convert_to_simple_graph
			end
		ensure
			node_count: node_count >= old node_count
			edge_count: edge_count >= old edge_count
			conflict: not merge_succeeded implies conflicting_edges.count > 0
		end

	plus alias "+" (other: like Current): like Current
			-- Union of current graph with `other'
			-- If `Current' is a simple graph, the result is a multigraph if necessary.
			-- Behavior (nodes): The node sets are unified by regular set union.
			-- Behavior (edges): Identical edges in `Current' and `other' appear only once
			-- in the resulting graph (=union of the edge sets).
			-- Notice: On success, the flag `merge_succeeded' in the resulting graph is set.
			-- If a conversion to multigraph is needed, but the current implementation
			-- has no multigraph support, the flag `merge_succeeded' is set to "False".
			-- All edges which could not be adopted are listed in `conflicting_edges'.
		require
			other_not_void: other /= Void
		do
			Result := empty_graph
			Result.merge_with (Current)
			Result.merge_with (other)
		ensure
			result_not_void: Result /= Void
			conflict: not Result.merge_succeeded implies Result.conflicting_edges.count > 0
		end

feature -- Obsolete

feature {NONE} -- Inapplicable

	extend (a_item: like item)
			-- Inapplicable because of `bag' postcondition.
		do
		end

	replace (a_item: like item)
			-- Inapplicable because nodes can not be modified.
		do
		end

feature {NONE} -- Implementation

	empty_graph: like Current
			-- Empty graph with the same actual type than `Current'
		deferred
		end

	conflicting_edges_impl: LINKED_LIST [like edge_item]
			-- Edges that could not be unified with current graph
			-- using the `merge_with' command.

	index_of_element: HASH_TABLE [INTEGER, like item]
			-- Gives the index of each item

	invalidate_cursor
			-- Invalidate cursor. `off' will be set to true.
		deferred
		ensure
			off: off
		end

	history_stack: ARRAYED_STACK [like cursor]
			-- History of the visited nodes


	-- Implementation for path finding algorithm

	annotated_nodes: ARRAY [NODE [like item, L]]
			-- All graph nodes annotated with additional information
			-- for the path finding algorithm

	border_nodes: INVERSE_HEAP_PRIORITY_QUEUE [NODE [like item, L]]
			-- Nodes which are part of the border set in the path finding algorithm

	node_from_item (a_item: like item): NODE [like item, L]
			-- Node object from item value
		require
			valid_item: a_item /= Void and has_node (a_item)
		local
			index: INTEGER
		do
			index := index_of_element.item (a_item)
			Result := annotated_nodes.item (index)
		ensure
			result_not_void: Result /= Void
		end

	prepare_path_finding
			-- Prepare data structure for path finding.
		local
			lin_rep: like linear_representation
			it: like item
			node: NODE [like item, L]
			index: INTEGER
		do
			-- Build `nodes' list.
			-- Use same indices as for ordinary items.
			create annotated_nodes.make (1, node_count)
			from
				lin_rep := linear_representation
				lin_rep.start
			until
				lin_rep.after
			loop
				it := lin_rep.item
				index := index_of_element.item (it)
				create node.make (it)
				annotated_nodes.force (node, index)
				lin_rep.forth
			end

			-- Make empty border set.
			create border_nodes.make (node_count)
		end

	path_impl: TWO_WAY_LIST [like edge_item]
			-- Path found by `find_path'
			-- (Feature was introduced because attributes
			-- cannot have a precondition right now)

	opposite_node (a_edge: like edge_item; a_node: like item): like item
			-- End node of `a_edge' when `a_node' is the start node
		do
			Result := a_edge.end_node
		end

	edge_length (a_edge: like edge_item): REAL_64
			-- Edge length, used in `find_path' algorithm
		require
			edge_not_void: a_edge /= Void
		do
			-- Unweighted edges are all considered to have equal length.
			Result := 1
		end

	merge_nodes (other: like Current)
			-- Merge all nodes of `other' into current graph.
		require
			other_not_void: other /= Void
		local
			item_linear: LINEAR [like item]
		do
			-- Put all nodes of `other' into current graph.
			from
				item_linear := other.nodes.linear_representation
				item_linear.start
			until
				item_linear.after
			loop
				put_node (item_linear.item)
				item_linear.forth
			end
		ensure
			node_count: node_count >= old node_count
		end

	merge_edges (other: like Current)
			-- Merge all edges of `other' into current graph.
			-- The union of the edge sets of `current' and `other' is built.
		require
			other_not_void: other /= Void
			multi_graph: is_multi_graph
		local
			edge_linear: like edges
			e: like edge_item
		do
			-- Merge edges of `other' into current graph.
			-- The resulting edge set is the mathematic union of both
			-- initial edge sets (important for multigraphs with several
			-- identical edges).
			from
				edge_linear := other.edges
				edge_linear.start
			until
				edge_linear.after
			loop
				e := edge_linear.item
				-- Union of edge sets.
				if edge_occurences (e) < other.edge_occurences (e) then
					adopt_edge (e)
				end
				edge_linear.forth
			end
		ensure
			edge_count: edge_count >= old edge_count
		end

	simple_merge_edges (other: like Current)
			-- Merge all edges of `other' into current graph.
			-- The simple graph property is preserved.
			-- Edges from `other' violating that property are ignored.
		require
			simple_graph: is_simple_graph
		local
			edge_linear: like edges
			e: like edge_item
		do
			-- Merge edges of `other' into current graph.
			-- Only edges preserving the simple graph property are processed.
			from
				edge_linear := other.edges
				edge_linear.start
				create conflicting_edges_impl.make
			until
				edge_linear.after
			loop
				e := edge_linear.item
				if not has_edge_between (e.start_node, e.end_node) then
					adopt_edge (e)
				else
					set_merge_succeeded (False)
					conflicting_edges_impl.extend (e)
				end
				edge_linear.forth
			end
		ensure
			conflict: not merge_succeeded implies conflicting_edges.count > 0
			edge_count: edge_count >= old edge_count
		end

	adopt_edge (a_edge: EDGE [like item, L])
			-- Put `a_edge' into current graph.
		require
			edge_not_void: a_edge /= Void
		do
			put_edge (a_edge.start_node, a_edge.end_node, a_edge.label)
		ensure
			edge_adopted: has_edge (a_edge)
			simple_edge_count: is_simple_graph implies edge_count = old edge_count + 1
			symmetric_edge_count: is_simple_graph implies edge_count = old edge_count + 2
		end

feature {NONE} -- Status setting

	set_path_found (a_value: BOOLEAN)
			-- Set `path_found' to `a_value'.
		deferred
		ensure
			path_found_set: path_found = a_value
		end

	set_merge_succeeded (a_value: BOOLEAN)
			-- Set `merge_succeeded' to `a_value'.
		deferred
		ensure
			merge_succeeded_set: merge_succeeded = a_value
		end

	set_is_simple_graph (a_value: BOOLEAN)
			-- Set `is_simple_graph' to `a_value'.
		deferred
		ensure
			is_simple_graph_set: is_simple_graph = a_value
		end

	set_is_symmetric_graph (a_value: BOOLEAN)
			-- Set `is_symmetric_graph' to `a_value'.
		deferred
		ensure
			is_symmetric_graph_set: is_symmetric_graph = a_value
		end

invariant

	valid_in_degree: not off implies in_degree >= 0
	valid_out_degree: not off implies out_degree >= 0

	edge_in_focus: not off and has_links implies edge_item /= Void

	history_stack_item_not_void: not history_stack.is_empty implies history_stack.item /= Void
	item_index_not_void: index_of_element /= Void

end -- class GRAPH
