note
	description: "[
		Directed weighted graphs, implemented on the basis
		of an adjacency matrix.
		Simple and symmetric graphs are supported.
		]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"

class
	ADJACENCY_MATRIX_WEIGHTED_GRAPH [G -> HASHABLE, reference L]

inherit
	ADJACENCY_MATRIX_GRAPH [G, L]
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
			make_empty_graph as make_empty_adjacency_matrix_graph
		undefine
			has_node,
			has_edge,
			has_cycles,
			has_links,
			node_count,
			edge_count,
			target,
			unweighted_edge_from_values,
			out_degree,
			forth,
			out
		redefine
--			border_nodes,
--			edge_item
		end

create
	make_simple_graph,
	make_symmetric_graph

feature -- Access

	edge_item: WEIGHTED_EDGE [like item, L] is
			-- Current edge
		do
			if current_target_node_index /= -1 then
				Result := adjacency_matrix.item (current_node_index, current_target_node_index)
			else
				Result := Void
			end
		end

	edge_from_values (a_start_node, a_end_node: like item; a_label: L; a_weight: REAL_64): like edge_item is
			-- Edge that matches `a_start_node', `a_end_node', `a_label' and `a_weight'.
			-- Result is Void if there is no match.
			-- The cursor is not moved.
		local
			start_index, end_index: INTEGER
			edge: like edge_item
		do
			if has_node (a_start_node) and has_node (a_end_node) then
				start_index := index_of_element.item (a_start_node)
				end_index := index_of_element.item (a_end_node)
				edge := adjacency_matrix.item (start_index, end_index)
				if edge /= Void and then equal (edge.label, a_label) and then equal (edge.weight, a_weight) then
					Result := edge
				else
					Result := Void
				end
			else
				Result := Void
			end
		end

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	put_edge (a_start_node, a_end_node: G; a_label: L; a_weight: REAL_64) is
			-- Create an edge with weight `a_weight' between `a_start_node' and `a_end_node'.
			-- The edge will be labeled `a_label'.
			-- For symmetric graphs, another edge is inserted in the opposite direction.
			-- The cursor is not moved.
		local
			edge: WEIGHTED_EDGE [G, L]
			start_index, end_index: INTEGER
		do
			start_index := index_of_element.item (a_start_node)
			end_index := index_of_element.item (a_end_node)
			create edge.make_directed (a_start_node, a_end_node, a_label, a_weight)
			adjacency_matrix.put (edge, start_index, end_index)
			internal_edges.extend (edge)
			if is_symmetric_graph and (a_start_node /= a_end_node) then
				create edge.make_directed (a_end_node, a_start_node, a_label, a_weight)
				adjacency_matrix.put (edge, end_index, start_index)
				internal_edges.extend (edge)
			end

			-- Update index bounds if necessary.
			if end_index < first_edge_index then
				first_edge_index := end_index
			elseif end_index > last_edge_index then
				last_edge_index := end_index
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

	out: STRING is
			-- Textual representation of the graph
		local
			i, j: INTEGER
			node: G
			label: ANY
			edge: WEIGHTED_EDGE [G, L]
		do
			Result := "digraph adjacency_matrix_graph%N"
			Result.append ("{%N")
			from
				i := 1
			until
				i > node_array.count
			loop
				node := node_array.item (i)
				Result.append ("%"")
				Result.append (node.out)
				Result.append ("%";%N")
				from
					j := 1
				until
					j > node_array.count
				loop
					edge := adjacency_matrix.item (i, j)
					if
						edge /= Void
					then
						Result.append ("  %"")
						Result.append (node.out)
						Result.append ("%" -> %"")
						Result.append (node_array.item (j).out)
						Result.append ("%" [label=%"")
						label := edge.label
						if label /= Void and then not label.out.is_equal ("") then
							Result.append (label.out)
							Result.append ("\n")
						end
						Result.append ("w = ")
						Result.append (edge.weight.out)
						Result.append ("%"];%N")
					end
					j := j + 1
				end
				i := i + 1
			end
			Result.append ("}%N")
		end

end -- class ADJACENCY_MATRIX_WEIGHTED_GRAPH
