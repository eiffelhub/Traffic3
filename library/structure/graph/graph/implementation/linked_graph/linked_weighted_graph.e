note
	description: "[
		Directed weighted graphs, implemented as
		dynamically linked structure.
		Simple graphs, multigraphs, symmetric graphs
		and symmetric multigraphs are supported.
		]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"

class
	LINKED_WEIGHTED_GRAPH [G -> HASHABLE, reference L]

inherit
	LINKED_GRAPH [G, L]
		rename
			put_edge as put_unweighted_edge,
			put_unlabeled_edge as put_unweighted_unlabeled_edge,
			edge_from_values as unweighted_edge_from_values
		export {NONE}
			put_unweighted_edge,
			put_unweighted_unlabeled_edge,
			unweighted_edge_from_values
		undefine
			adopt_edge,
			edge_length,
			put_unweighted_edge
		redefine
			edge_item,
			out
		end

	WEIGHTED_GRAPH [G, L]
		rename
			make_empty_graph as make_empty_linked_graph
		undefine
			make_simple_graph,
			make_symmetric_graph,
			make_multi_graph,
			make_symmetric_multi_graph,
			has_node,
			has_edge,
			has_cycles,
			has_links,
			node_count,
			edge_count,
			target,
			out_degree,
			unweighted_edge_from_values,
			forth,
			out
--		redefine
--			border_nodes
		end

create
	make_simple_graph,
	make_symmetric_graph,
	make_multi_graph,
	make_symmetric_multi_graph

feature -- Access

	edge_item: LINKED_GRAPH_WEIGHTED_EDGE [like item, L]
			-- Current edge
		do
			if not current_node.edge_list.off then
				Result ?= current_node.edge_list.item
			else
				Result := Void
			end
		end

	edge_from_values (a_start_node, a_end_node: like item; a_label: L; a_weight: REAL_64): like edge_item
			-- Edge that matches `a_start_node', `a_end_node', `a_label' and `a_weight'.
			-- Result is Void if there is no match.
			-- The cursor is not moved.
		local
			start_node, end_node: like current_node
			edge: like edge_item
		do
			if has_node (a_start_node) and has_node (a_end_node) then
				start_node := linked_node_from_item (a_start_node)
				end_node := linked_node_from_item (a_end_node)
				create edge.make_directed (start_node, end_node, a_label, a_weight)

				if has_edge (edge) then
					Result := edge
				else
					Result := Void
				end
			end
		end

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	put_edge (a_start_node, a_end_node: like item; a_label: L; a_weight: REAL_64)
			-- Create an edge with weight `a_weight' between `a_start_node' and `a_end_node'.
			-- The edge will be labeled `a_label'.
			-- For symmetric graphs, another edge is inserted in the opposite direction.
		local
			start_node, end_node: like current_node
			edge: like edge_item
		do
			start_node := linked_node_from_item (a_start_node)
			end_node := linked_node_from_item (a_end_node)
			create edge.make_directed (start_node, end_node, a_label, a_weight)
			start_node.put_edge (edge)
			internal_edges.extend (edge)
			if is_symmetric_graph and start_node /= end_node then
				create edge.make_directed (end_node, start_node, a_label, a_weight)
				end_node.put_edge (edge)
				internal_edges.extend (edge)
			end
		end

feature -- Removal

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
			node: like current_node
			edge: like edge_item
			i, index: INTEGER
			label: L
		do
			Result := "digraph linked_weighted_graph%N"
			Result.append ("{%N")
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
					-- Store previous cursor position
					index := node.edge_list.index
					node.edge_list.start
				until
					node.edge_list.exhausted
				loop
					Result.append ("  %"")
					Result.append (node.item.out)
					Result.append ("%" -> %"")
					edge ?= node.edge_list.item
					Result.append (edge.end_node.out)
					Result.append ("%" [label=%"")
					label := edge.label
					if label /= Void and then not label.out.is_equal ("") then
						Result.append (label.out)
						Result.append ("\n")
					end
					Result.append ("w = ")
					Result.append (edge.weight.out)
					Result.append ("%"];%N")
					node.edge_list.forth
				end
				if node.edge_list.valid_index (index) then
					node.edge_list.go_i_th (index)
				end
				i := i + 1
			end
			Result.append ("}%N")
		end

end -- class LINKED_WEIGHTED_GRAPH
