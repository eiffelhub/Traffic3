note
	description: "[
		Directed graphs, implemented as dynamically linked structure.
		Simple graphs, multigraphs, symmetric graphs and symmetric
		multigraphs are supported.
		]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	LINKED_GRAPH [G -> HASHABLE, reference L]

inherit
	GRAPH [G, L]
		rename
			make_empty_graph as make_empty_linked_graph
		redefine
			node_count,
			edge_count,
			has_edge,
			has_links,
			out_degree,
			forth,
			out
		end

	ITERATION_CURSOR [G]
		undefine
			out
		end
create
	make_simple_graph,
	make_symmetric_graph,
	make_multi_graph,
	make_symmetric_multi_graph

feature {NONE} -- Initialization

	make_empty_linked_graph
			-- Make an empty linked graph.
		do
			create node_list.make (1, 0)
			create inactive_nodes.make (0)
			create index_of_element.make (0)
			invalidate_cursor
			create internal_edges.make (0)
			internal_edges.compare_objects
			create history_stack.make (0)
			object_comparison := True
		ensure then
			no_nodes: node_list.is_empty
			empty_edge_list: internal_edges.is_empty
		end

feature -- Access

	nodes,vertices: SET [like item]
			-- All nodes of the graph
		local
			i: INTEGER
		do
			-- Put all items of the node list into a set.
			create {ARRAYED_SET [like item]} Result.make (0)
			from
				i := 1
			until
				i > node_count + inactive_nodes.count
			loop
				if valid_index (i) then
					Result.extend (node_list.item (i).item)
				end
				i := i + 1
			end
		end

	edges: LIST [like edge_item]
			-- All edges of the graph
		do
			Result := internal_edges.twin
		end

	item: G
			-- Value of the currently focused node
		do
			Result := current_node.item
		end

	edge_item: LINKED_GRAPH_EDGE [like item, L]
			-- Current edge
		do
			if not current_node.edge_list.off then
				Result := current_node.edge_list.item
			else
				Result := Void
			end
		end

	incident_edges: LIST [like edge_item]
			-- All incident edges of `item'
		local
			edge_list: TWO_WAY_CIRCULAR [like edge_item]
			index: INTEGER
		do
			create {ARRAYED_LIST [like edge_item]} Result.make (out_degree)

			-- Backup current cursor.
			index := current_node.edge_list.index

			from
				edge_list := current_node.edge_list
				edge_list.start
			until
				edge_list.exhausted
			loop
				Result.extend (edge_list.item)
				edge_list.forth
			end

			-- Restore old cursor.
			if edge_list.valid_index (index) then
				edge_list.go_i_th (index)
			end
		end

	incident_edge_labels: LIST [L]
			-- Labels of all incident edges of `item'
		local
			edge_list: TWO_WAY_CIRCULAR [like edge_item]
			index: INTEGER
		do
			create {ARRAYED_LIST [L]} Result.make (out_degree)

			-- Backup current cursor.
			index := current_node.edge_list.index

			from
				edge_list := current_node.edge_list
				edge_list.start
			until
				edge_list.exhausted
			loop
				Result.extend (edge_list.item.label)
				edge_list.forth
			end

			-- Restore old cursor.
			if edge_list.valid_index (index) then
				edge_list.go_i_th (index)
			end
		end

	edge_from_values (a_start_node, a_end_node: like item; a_label: L): like edge_item
			-- Edge that matches `a_start_node', `a_end_node' and `a_label'.
			-- Result is Void if there is no match.
			-- The cursor is not moved.
		local
			start_node, end_node: like current_node
			edge: like edge_item
		do
			if has_node (a_start_node) and has_node (a_end_node) then
				start_node := linked_node_from_item (a_start_node)
				end_node := linked_node_from_item (a_end_node)
				create edge.make_directed (start_node, end_node, a_label)
				if has_edge (edge) then
					Result := edge
				else
					Result := Void
				end
			end
		end

	node_identity: HASHABLE
			-- Object that identifies the current item
		do
			Result := current_node.item
		end

feature -- Measurement

	node_count: INTEGER
			-- Number of nodes in the graph

	edge_count: INTEGER
			-- Number of edges in the graph
		do
			Result := internal_edges.count
		end

	in_degree: INTEGER
			-- Number of incoming edges of the current node
		do
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
			debug ("in_degree")
				print ("in_degree of `" + item.out + "'%N")
			end
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
			from
				internal_edges.start
				Result := 0
			until
				internal_edges.after
			loop
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
				debug ("in_degree")
					print ("edge: " + internal_edges.item.out + "%N")
				end
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
				if internal_edges.item.internal_end_node = current_node then
					Result := Result + 1
				end
				internal_edges.forth
			end
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
			debug ("in_degree")
				print ("RESULT = " + Result.out + "%N%N")
			end
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
		end

	out_degree: INTEGER
			-- Number of outgoing edges of `item'
		do
			Result := current_node.out_degree
		end

feature -- Status report

	has_multi_graph_support: BOOLEAN
			-- Are multigraphs supported by the current implementation?
		do
			Result := True
		end

	has_edge (a_edge: EDGE [like item, L]): BOOLEAN
			-- Is `a_edge' part of the graph?
		local
			linked_graph_edge: like edge_item
			node: like current_node
			index: INTEGER
		do
			linked_graph_edge ?= a_edge
			if linked_graph_edge /= Void then
				node := linked_graph_edge.internal_start_node
			else
				node := linked_node_from_item (a_edge.start_node)
			end

			from
				index := node.edge_list.index
				node.edge_list.start
			until
				node.edge_list.exhausted or else a_edge.is_equal (node.edge_list.item)
			loop
				node.edge_list.forth
			end

			Result := not node.edge_list.exhausted

			-- Restore edge list cursor.
			node.edge_list.go_i_th (index)
		end

	has_edge_between (a_start_node, a_end_node: like item): BOOLEAN
			-- Are `a_start_node' and `a_end_node' directly connected?
			-- Note: Edges are directed.
		local
			index: INTEGER
			start_node, end_node: like current_node
			el: TWO_WAY_CIRCULAR [like edge_item]
		do
			start_node := linked_node_from_item (a_start_node)
			end_node := linked_node_from_item (a_end_node)
			el := start_node.edge_list

			-- Make backup of cursor.
			index := el.index

			from
				el.start
			until
				Result or el.exhausted
			loop
				if el.item.internal_end_node = end_node then
					Result := True
				end
				el.forth
			end

			-- Restore cursor.
			if el.valid_index (index) then
				el.go_i_th (index)
			end
		end

	has_links: BOOLEAN
			-- Does the current node have outgoing edges (links)?
		do
			Result := not current_node.edge_list.is_empty
		end

	is_first_edge: BOOLEAN
			-- Is the focused edge the first one?
		do
			Result := current_node.edge_list.index = 1
		end

	path_found: BOOLEAN
			-- Has a path been found in `find_path'?

	is_simple_graph: BOOLEAN
			-- Is the graph a simple graph?
			-- (i.e. at most one edge between two nodes)

	is_symmetric_graph: BOOLEAN
			-- Is the graph symmetric?

	merge_succeeded: BOOLEAN
			-- Was the invocation of `merge_with' successful?

	exhausted: BOOLEAN
			-- Has `left' or `right' turned to the first link?

	after, off: BOOLEAN
			-- Does `cursor' currently denote a valid graph position?
		do
			Result := current_node = Void
		end

	Full: BOOLEAN = False
			-- Is the maximum number of nodes reached?

feature -- New Cursor

	new_cursor: LINKED_GRAPH [G, L]
		do
			Result := twin
			Result.start
		end

feature -- Cursor movement

	start
			-- Turn to the first link.
		do
			current_node.edge_list.start
			exhausted := current_node.out_degree = 0
		end

	left
			-- Turn one edge to the left.
		do
			current_node.edge_list.back
			if current_node.edge_list.index = 1 then
				exhausted := True
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
			else
				debug ("left")
					print (" index = ")
					print (current_node.edge_list.index)
					print (", out_degree = ")
					print (out_degree)
					print (" ")
				end
----- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG --- DEBUG -----
			end
		end

	right
			-- Turn one edge to the right.
		do
			current_node.edge_list.forth
			if current_node.edge_list.index = 1 then
				exhausted := True
			end
		end

	forth
			-- Walk along the currently focused edge.
		do
			history_stack.extend (cursor)
			current_node := edge_item.internal_end_node
			start
		end

	search (a_item: like item)
			-- Move to `a_item'. If no such position exists, `off' will be true.
		do
			if has_node (a_item) then
				current_node := linked_node_from_item (a_item)
				start
			else
				current_node := Void
			end
		end

feature -- Element change

	put_node (a_node: like item)
			-- Insert a new node in the graph if it is not already present.
			-- The cursor is not moved.
		local
			index: INTEGER
			node: like current_node
		do
			if not index_of_element.has (a_node) then
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
				create node.make (a_node)
				node_list.force (node, index)
				index_of_element.force (index, a_node)
				node_count := node_count + 1
			end
		end

	put_edge (a_start_node, a_end_node: like item; a_label: L)
			-- Create an edge between `a_start_node' and `a_end_node'
			-- and set its label to `a_label'.
			-- For symmetric graphs, another edge is inserted in the opposite direction.
			-- The cursor is not moved.
		local
			start_node, end_node: like current_node
			edge: like edge_item
		do
			start_node := linked_node_from_item (a_start_node)
			end_node := linked_node_from_item (a_end_node)
			create edge.make_directed (start_node, end_node, a_label)
			start_node.put_edge (edge)
			internal_edges.extend (edge)
			if is_symmetric_graph and start_node /= end_node then
				create edge.make_directed (end_node, start_node, a_label)
				end_node.put_edge (edge)
				internal_edges.extend (edge)
			end
		end

feature -- Removal

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

	prune_edge (a_edge: EDGE [like item, L])
			-- Remove `a_edge' from the graph.
		local
			linked_edge, symmetric_edge: like edge_item
			start_node, end_node: like current_node
		do
			prune_edge_impl (a_edge)
			if is_symmetric_graph then
				-- Find both start and end node in the node list.
				linked_edge ?= a_edge
				if linked_edge /= Void then
					start_node := linked_edge.internal_start_node
					end_node := linked_edge.internal_end_node
				else
					start_node := linked_node_from_item (a_edge.start_node)
					end_node := linked_node_from_item (a_edge.end_node)
				end
				create symmetric_edge.make_directed (end_node, start_node, a_edge.label)
				prune_edge_impl (symmetric_edge)
			end
		end

	prune_edge_between (a_start_node, a_end_node: like item)
			-- Remove the edge connecting `a_start_node' and `a_end_node'.
			-- This operation is only permitted on simple graphs because of ambiguity.
		local
			c: like cursor
		do
			-- Make backup of cursor if necessary.
			if not off then
				c := cursor
			end

			-- Search for the start node and prune the current edge.
			search (a_start_node)
			turn_to_target (a_end_node)
			remove_edge

			-- Restore old cursor.
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature -- Output

	out: STRING
			-- Printable representation of the graph
		local
			i: INTEGER
			node: like current_node
			edge: like edge_item
			index: INTEGER
			label: L
		do
			Result := "digraph linked_graph%N"
			Result.append ("{%N")
			-- Iterate over all nodes.
			from
				i := 1
			until
				i > node_list.count
			loop
				if valid_index (i) then
					node := node_list.item (i)
					Result.append ("%"")
					Result.append (node.item.out)
					Result.append ("%";%N")
					-- Iterate over all incident edges.
					from
						-- Store previous cursor position
						index := node.edge_list.index
						node.edge_list.start
					until
						node.edge_list.exhausted
					loop
						Result.append ("  %"")
						Result.append (node.item.out)
						Result.append ("%" -> %"")
						edge := node.edge_list.item
						Result.append (edge.end_node.out)
						Result.append ("%"")
						label := edge.label
						if label /= Void and then not label.out.is_equal ("") then
							Result.append (" [label=%"")
							Result.append (label.out)
							Result.append ("%"]")
						end
						Result.append (";%N")
						node.edge_list.forth
					end
					if node.edge_list.valid_index (index) then
						node.edge_list.go_i_th (index)
					end
				end
				i := i + 1
			end
			Result.append ("}%N")
		end

feature {NONE} -- Implementation

	node_list: ARRAY [like current_node]
			-- Node list

	inactive_nodes: ARRAYED_SET [INTEGER]
			-- Indices which are currently not in use.

	current_node: LINKED_GRAPH_NODE [like item, L]
			-- Current node in the list

	internal_edges: ARRAYED_LIST [like edge_item]
			-- Set of all edges of the graph

	empty_graph: like Current
			-- Empty graph with the same actual type than `Current'
		do
			if is_simple_graph then
				if is_symmetric_graph then
					create Result.make_symmetric_graph
				else
					create Result.make_simple_graph
				end
			else
				if is_symmetric_graph then
					create Result.make_symmetric_multi_graph
				else
					create Result.make_multi_graph
				end
			end
		end

	valid_index (a_index: INTEGER): BOOLEAN
			-- If `a_index' a valid index for `node_list'?
		require
			positive: a_index > 0
		do
			Result := (a_index <= node_list.count) and not inactive_nodes.has (a_index)
		end

	linked_node_from_item (a_item: G): like current_node
			-- Find the node with item `a_item'.
		require
			has_node (a_item)
		local
			index: INTEGER
		do
			index := index_of_element.item (a_item)
			Result := node_list.item (index)
		ensure
			node_found: Result /= Void
			correct_result: Result.item.is_equal (a_item)
		end

	prune_edge_impl (a_edge: EDGE [like item, L])
			-- Remove `a_edge' from the graph.
		require
			edge_exists: has_edge (a_edge)
		local
			linked_edge: like edge_item
			start_node, end_node: like current_node
			c: like cursor
		do
			linked_edge ?= a_edge

			-- Find both start and end node in the node list.
			if linked_edge /= Void then
				start_node := linked_edge.internal_start_node
				end_node := linked_edge.internal_end_node
			else
				start_node := linked_node_from_item (a_edge.start_node)
				end_node := linked_node_from_item (a_edge.end_node)
				create linked_edge.make_directed (start_node, end_node, a_edge.label)
			end

			-- Turn cursor if `edge_item' is removed.
			if (not off) and then linked_edge.is_equal (edge_item) then
				right
			end

			-- Make backup of cursor if necessary.
			if not off then
				c := cursor
			end

			-- Remove edge from linked graph representation.
			current_node := start_node
			turn_to_edge (a_edge)
			current_node.edge_list.remove

			if internal_edges.has (linked_edge) then
				internal_edges.start
				internal_edges.prune (linked_edge)
			end

			-- Restore cursor.
			if c /= Void then
				go_to (c)
			else
				invalidate_cursor
			end
		end

	invalidate_cursor
			-- Invalidate cursor. `off' will be set to true.
		do
			current_node := Void
		end

feature {NONE} -- Status setting

	set_path_found (a_value: BOOLEAN)
			-- Set `path_found' to `a_value'.
		do
			path_found := a_value
		end

	set_merge_succeeded (a_value: BOOLEAN)
			-- Set `merge_succeeded' to `a_value'.
		do
			merge_succeeded := a_value
		end

	set_is_simple_graph (a_value: BOOLEAN)
			-- Set `is_simple_graph' to `a_value'.
		do
			is_simple_graph := a_value
		end

	set_is_symmetric_graph (a_value: BOOLEAN)
			-- Set `is_symmetric_graph' to `a_value'.
		do
			is_symmetric_graph := a_value
		end


invariant

	node_list_not_void: node_list /= Void
	edge_list_not_void: internal_edges /= Void

	off_when_no_nodes: node_list.is_empty implies off

end -- class LINKED_GRAPH
