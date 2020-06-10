note
	description	: "[
			Topological sorter.
			Used to produce a total order on a set of
			elements having only a partial order.
			]"
	author: "Olivier Jeger"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TOPOLOGICAL_SORTER [G -> HASHABLE]

create
	make

feature {NONE} -- Initialization

	make
			-- Create topological sorter.
		do
			create index_of_element.make (1)
			create element_of_index.make (1, 0)
			create successors.make (1, 0)
			create predecessor_count.make (1, 0)
			use_fifo_output
			count := 0
		ensure
			index_of_element_not_void: index_of_element /= Void
			element_of_index_not_void: element_of_index /= Void
			successors_not_void: successors /= Void
			predecessor_count_not_void: predecessor_count /= Void
			fifo_output: fifo_output
		end

feature -- Initialization

	record_element (e: G)
			-- Add `e' to the set of elements, unless already present.
		require
			not_sorted: not done
		do
			index_of_element.put (count+1, e)
			if index_of_element.inserted then
				count := count + 1
				element_of_index.force (e, count)
				predecessor_count.force (0, count)
				successors.force (create {LINKED_LIST [INTEGER]}.make, count)
			end
		end

	record_constraint (e, f: G)
			-- Add the constraint `[e,f]'.
		require
			not_sorted: not done
			not_void: e /= Void and f /= Void
		local
			x, y: INTEGER
		do
			-- Ensure `e' and `f' are inserted (no effect if they already were):
			record_element (e)
			record_element (f)

			x := index_of_element.item (e)
			y := index_of_element.item (f)
			predecessor_count.put (predecessor_count.item (y) + 1, y)
			add_successor (x, y)
		end

feature -- Access

	cycle_found: BOOLEAN
			-- Did the original constraint imply a cycle?
		require
			sorted: done
		do
			Result := has_cycle
		end

	cycle_list: LIST [G]
			-- Elements involved in cycles
		require
			sorted: done
		do
			Result := cycle_list_impl
		ensure
			void_iff_none: (not cycle_found) = (Result = Void)
			not_empty_if_cycle: cycle_found implies (not Result.is_empty)
		end

	sorted_elements: LIST [G]
			-- List, in an order respecting the constraints, of all
			-- the elements that can be ordered in that way
		require
			sorted: done
		do
			Result := output
		end

feature -- Measurement

	count: INTEGER
			-- Number of elements

feature -- Status report

	done: BOOLEAN
			-- Has topological sort been performed?

	object_comparison: BOOLEAN
			-- Must `record_element' operations use `equal' rather than `='
			-- to avoid duplicate elements?

	fifo_output: BOOLEAN
			-- Are elements without constraints added to output by
			-- FIFO (first in first out) strategy?

feature -- Status setting

	reset
			-- Allow further updates of the elements and constraints.
		do
			done := False
			has_cycle := False
			cycle_list_impl := Void
			processed_count := 0
		ensure
			fresh: not done
		end

	compare_references
			-- Ensure that future `record_element' operations will use `='
			-- rather than `equal' for comparing references.
		require
			empty: count = 0
		do
			object_comparison := False
			element_of_index.compare_references
		ensure
			reference_comparison: not object_comparison
		end

	compare_objects
			-- Ensure that future `record_element' operations will use `equal'
			-- rather than `=' for comparing references.
		require
			empty: count = 0
		do
			object_comparison := True
			element_of_index.compare_objects
		ensure
			object_comparison: object_comparison
		end

	use_fifo_output
			-- Elements without constraints are added to output with
			-- FIFO (first in first out) strategy.
		require
			not_sorted: not done
		do
			create {LINKED_QUEUE [INTEGER]} candidates.make
			fifo_output := True
		ensure
			fifo_output: fifo_output
		end

	use_lifo_output
			-- Elements without constraints are added to output with
			-- LIFO (last in first out) strategy.
		require
			not_sorted: not done
		do
			create {ARRAYED_STACK [INTEGER]} candidates.make (1)
			fifo_output := False
		ensure
			lifo_output: not fifo_output
		end

feature -- Cursor movement

feature -- Element change

	process
			-- Perform a topological sort over all applicable elements.
			-- Results are accessible through `sorted', `cycle_found' and `cycle_list'.
		require
			not_sorted: not done
		local
			x, y: INTEGER
			e: G
			x_successors: LIST [INTEGER]
		do
			from
				create output.make
				find_initial_candidates
			until
				candidates.is_empty
			loop
				x := candidates.item
				candidates.remove
				e := element_of_index.item (x)
				output.extend (e)
				x_successors := successors.item (x)		-- A list
				from
					x_successors.start
				until
					x_successors.after
				loop
					y := x_successors.item
					predecessor_count.put (predecessor_count.item (y) - 1, y)
					if predecessor_count.item (y) = 0 then
						candidates.put (y)
					end
					x_successors.forth
				end
				processed_count := processed_count + 1
			end
			report_cycles
			done := True
		ensure
			sorted: done
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

feature {NONE} -- Implementation

	successors: ARRAY [LINKED_LIST [INTEGER]]
			-- Indexed by element numbers; for each element `x',
			-- gives the list of its successors (the elements `y'
			-- such that there is a constraint `[x,y]')

	predecessor_count: ARRAY [INTEGER]
			-- Indexed by element numbers; for each, says how many
			-- predecessors the element has

	candidates: DISPENSER [INTEGER]
			-- Elements with no predecessor, ready to be released

	processed_count: INTEGER
			-- Number of sorted elements

	has_cycle: like cycle_found
			-- Internal attribute with same value as `cycle_found'.
			-- (needed because `cycle_found' has precondition `done'.)

	cycle_list_impl: like cycle_list
			-- Internal attribute with same value as `cycle_list'.
			-- (needed because `cycle_list' has precondition `done'.)

	output: LINKED_LIST [G]
			-- Internal attribute with same value as `sorted'.
			-- (needed because `sorted' has precondition `done'.)


	index_of_element: HASH_TABLE [INTEGER, G]
			-- Index of every element

	element_of_index: ARRAY [G]
			-- For every assigned index, gives the associated element

	find_initial_candidates
			-- Insert into `candidates' any elements without predecessors.
		require
			predecessor_count_not_void: predecessor_count /= Void
			candidates_not_void: candidates /= Void
		local
			x: INTEGER
		do
			from
				x := 1
			until
				x > count
			loop
				if predecessor_count.item (x) = 0 then
					candidates.force (x)
				end
				x := x + 1
			end
		end

	report_cycles
			-- Make information about cycles available to clients
		local
			x: INTEGER
			e: G
		do
			if processed_count < count then
				-- There was a cycle in the original relation
				has_cycle := True
				create {LINKED_LIST [G]} cycle_list_impl.make
				from
					x := 1
				until
					x > count
				loop
					if predecessor_count.item (x) /= 0 then
						-- item with index `x' was involved in a cycle
						e := element_of_index.item (x)
						cycle_list_impl.extend (e)
					end
					x := x + 1
				end
			end
		end

	add_successor (x, y: INTEGER)
			-- Record `y' as successor of `x'.
		require
			valid_x: 1 <= x; x <= count
			valid_y: 1 <= y; y <= count
		local
			x_successors: LINKED_LIST [INTEGER]
		do
			x_successors := successors.item (x)
			-- The successor list for `x' may not have been created yet:
			if x_successors = Void then
				create x_successors.make
				successors.put (x_successors, x)
			end
			x_successors.extend (y)
		ensure
			has_successor: successors.item (x).has (y)
		end

invariant

	elements_not_void:			element_of_index /= Void
	hash_table_not_void:		index_of_element /= Void
	predecessor_count_not_void:	predecessor_count /= Void
	successors_not_void:		successors /= Void
	candidates_not_void:		candidates /= Void

	element_count:			element_of_index.count = count
	predecessor_list_count:	predecessor_count.count = count
	successor_list_count:	successors.count = count

	cycle_list_iff_cycle: done implies (cycle_found = (cycle_list /= Void))

	all_items_sorted:  (done and then not cycle_found) implies (count = sorted_elements.count)
	no_item_forgotten: (done and then cycle_found) implies (count = sorted_elements.count + cycle_list.count)
	processed_count:   done implies processed_count = sorted_elements.count

end -- class TOPOLOGICAL_SORTER
