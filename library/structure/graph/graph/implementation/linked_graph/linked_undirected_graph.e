note
	description: "[
		Undirected graphs, implemented as dynamically linked structure.
		Both simple graphs and multigraphs are supported.
		]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2009-04-06 14:42:41 +0200 (Пн, 06 апр 2009) $"
	revision: "$Revision: 1086 $"

class
	LINKED_UNDIRECTED_GRAPH [G -> HASHABLE, reference L]

inherit
	LINKED_GRAPH [G, L]
		rename
			in_degree as degree,
			out_degree as degree
		export {NONE}
			is_dag
		undefine
			adopt_edge,
			components,
			put_unlabeled_edge,
			edge_count,
			has_cycles,
			is_dag,
			is_connected,
			is_eulerian,
			opposite_node
		redefine
			empty_graph,
			has_edge_between,
			put_edge,
			degree,
			prune_edge,
			out
		end

	UNDIRECTED_GRAPH [G, L]
		rename
			make_empty_graph as make_empty_linked_graph
		undefine
			make_simple_graph,
			make_symmetric_graph,
			make_multi_graph,
			make_symmetric_multi_graph,
			has_node,
			has_edge,
			has_links,
			target,
			degree,
			node_count,
			forth,
			out
		end

create
	make_simple_graph, make_multi_graph

feature -- Access

feature -- Measurement

	degree: INTEGER
			-- Number of edges attached to `item'
		do
			Result := current_node.out_degree
		end

feature -- Status report

	has_edge_between (a_start_node, a_end_node: like item): BOOLEAN
			-- Are `a_start_node' and `a_end_node' directly connected?
		local
			index: INTEGER
			start_node: like current_node
			el: TWO_WAY_CIRCULAR [like edge_item]
		do
			start_node := linked_node_from_item (a_start_node)
			el := start_node.edge_list

			-- Make backup of cursor.
			index := el.index

			from
				el.start
			until
				Result or el.exhausted
			loop
				if el.item.opposite_node (a_start_node).is_equal (a_end_node) then
					Result := True
				end
				el.forth
			end

			-- Restore cursor.
			if el.valid_index (index) then
				el.go_i_th (index)
			end
		end

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	put_edge (a_start_node, a_end_node: like item; a_label: L)
			-- Create an edge between `a_start_node' and `a_end_node'
			-- and set its label to `a_label'.
			-- The cursor is not moved.
		local
			start_node, end_node: like current_node
			edge: like edge_item
		do
			start_node := linked_node_from_item (a_start_node)
			end_node := linked_node_from_item (a_end_node)
			create edge.make_undirected (start_node, end_node, a_label)
			start_node.put_edge (edge)
			end_node.put_edge (edge)
			internal_edges.extend (edge)
		end

feature -- Removal

	prune_edge (a_edge: EDGE [like item, L])
			-- Remove `a_edge' from the graph.
			-- The cursor will turn right if `current_egde' is removed.
		local
			linked_edge: like edge_item
			start_node, end_node: like current_node
			c: like cursor
			index: INTEGER
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

			-- Backup current cursor if necessary.
			if not off then
				c := cursor
			end

			-- Remove edge from linked graph representation.
			-- Note: End node must be processed first.
			-- Otherwise, `turn_to_edge' produces contract violation.
			current_node := end_node
			index := current_node.edge_list.index
			turn_to_edge (a_edge)
			current_node.edge_list.remove
			if current_node.edge_list.valid_index (index) then
				current_node.edge_list.go_i_th (index)
			end

			current_node := start_node
			index := current_node.edge_list.index
			turn_to_edge (a_edge)

			if current_node.edge_list.valid_index (index)  then
				current_node.edge_list.go_i_th (index)
			end

			internal_edges.start
			internal_edges.prune (linked_edge)

			-- Restore cursor.
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
			-- Textual representation of the graph
		local
			i, index: INTEGER
			node: like current_node
			edge: like edge_item
			edges_todo: like edges
			label: ANY
		do
			Result := "graph linked_undirected_graph%N"
			Result.append ("{%N")

			edges_todo := edges.twin
			edges_todo.compare_objects

			from
				i := 1
			until
				i > node_count
			loop
				node := node_list.item (i)
				Result.append ("%"")
				Result.append (node.item.out)
				Result.append ("%";%N")
				from
					index := node.edge_list.index
					node.edge_list.start
				until
					node.edge_list.exhausted
				loop
					edge := node.edge_list.item
					if edges_todo.has (edge) then
						Result.append ("  %"")
						Result.append (node.item.out)
						Result.append ("%" -- %"")
						Result.append (edge.opposite_node (node.item).out)
						Result.append ("%"")
						label := node.edge_list.item.label
						if label /= Void and then not label.out.is_equal ("") then
							Result.append (" [label=%"")
							Result.append (label.out)
							Result.append ("%"]")
						end
						Result.append (";%N")
						edges_todo.start
						edges_todo.prune (edge)
					end
					node.edge_list.forth
				end
				if node.edge_list.valid_index (index) then
					node.edge_list.go_i_th (index)
				end
				i := i + 1
			end
			Result.append ("}%N")
		end

feature {NONE} -- Implementation

	empty_graph: like Current
			-- Empty graph with the same actual type than `Current'
		do
			if is_simple_graph then
				create Result.make_simple_graph
			else
				create Result.make_multi_graph
			end
		end

end -- class LINKED_UNDIRECTED_GRAPH
