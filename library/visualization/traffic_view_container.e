note
	description: "Container for city item views of a certain type"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_VIEW_CONTAINER [G, H->TRAFFIC_VIEW [G]]

feature -- Access

	count: INTEGER 
			-- Number of items in list
		deferred
		end

	item_for_iteration: H
			-- Item at internal cursor position
		require
			not_after: not after
		deferred
		end

	item (i: INTEGER_32): H
			-- Item at index `i'
		require
			valid_index: 1 <= i and i <= count
		deferred
		end

	view_for_item (a_item: G): H
			-- View for `a_item' if it exists
			-- (Result may be Void!)
		do
			from
				start
			until
				item_for_iteration.item = a_item or after
			loop
				forth
			end
			if not after then
				Result := item_for_iteration
			end
		end

feature -- Status report

	has (v: H): BOOLEAN
			-- Does list include `v'?
		deferred
		ensure
			not_empty: Result implies not is_empty
		end

	is_empty: BOOLEAN
			-- Is container empty?
		deferred
		end

	after: BOOLEAN
			-- Is there no item at internal cursor position?
		deferred
		end

	has_view_for_item (a_item: G): BOOLEAN
			-- Is there a view for `a_item'?
			-- (Result may be Void!)
		do
			from
				start
			until
				item_for_iteration.item = a_item or after
			loop
				forth
			end
			if not after then
				Result := True
			end
		end

	first: H
			-- First item in list
		require
			not_empty: not is_empty
		deferred
		ensure
			has_first: has (Result)
		end

	last: H
			-- Last item in list
		require
			not_empty: not is_empty
		deferred
		ensure
			definition: Result = item (count)
			has_last: has (Result)
		end

feature -- Insertion

	put_first (v: H)
			-- Add `v' to beginning of list.
			-- Do not move cursors.
		deferred
		ensure
			one_more: count = old count + 1
			inserted: first = v
		end

	put_last (v: H)
			-- Add `v' to end of list.
			-- Do not move cursors.
		deferred
		ensure
			added: has (v)
			one_more: count = old count + 1
			inserted: last = v
		end

	replace (v: H; i: INTEGER)
			-- Replace item at index `i' by `v'.
			-- Do not move cursors.
		require
			valid_index: 1 <= i and i <= count
		deferred
		ensure
			same_count: count = old count
			replaced: item (i) = v
		end

	put (v: H; i: INTEGER)
			-- Add `v' at `i'-th position.
			-- Do not move cursors.
		require
			valid_index: 1 <= i and i <= (count + 1)
		deferred
		ensure
			one_more: count = old count + 1
			inserted: item (i) = v
		end

feature -- Removal

	remove_first
			-- Remove item at beginning of list.
			-- Move any cursors at this position forth.
		require
			not_empty: not is_empty
		deferred
		ensure -- from DS_INDEXABLE
			one_less: count = old count - 1
		end

	remove_last
			-- Remove item at end of list.
			-- Move any cursors at this position forth.
		require
			not_empty: not is_empty
		deferred
		ensure
			one_less: count = old count - 1
		end

	remove (i: INTEGER_32)
			-- Remove item at `i'-th position.
			-- Move any cursors at this position forth.
		require
			not_empty: not is_empty
			valid_index: 1 <= i and i <= count
		deferred
		ensure
			one_less: count = old count - 1
		end

	delete (v: H)
			-- Remove all occurrences of `v'.
			-- Move all cursors off.
		deferred
		ensure
			deleted: not has (v)
		end

	wipe_out
			-- Remove all items from list.
			-- Move all cursors off.
		deferred
		ensure
			wiped_out: is_empty
		end

feature -- Cursor movement

	start
			-- Move internal cursor to first position.
		deferred
		ensure
			empty_behavior: is_empty implies after
			not_empty_behavior: not is_empty implies item_for_iteration = first
		end

	forth
			-- Move internal cursor to next position.
		require
			not_after: not after
		deferred
		end

feature -- Basic operations

	hide
			-- Hide all elements.
		do
			from
				start
			until
				after
			loop
				item_for_iteration.hide
				forth
			end
		end

	show
			-- Show all elements.
		do
			from
				start
			until
				after
			loop
				item_for_iteration.show
				forth
			end
		end


end
