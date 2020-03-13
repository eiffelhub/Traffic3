indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_RENDERABLE_CONTAINER [G]

inherit

	TE_3D_NODE
		rename
			add_child as put_last,
			remove_child as delete,
			remove_all_children as wipe_out
		redefine
			make_as_child,
			internal_children,
			put_last,
			delete,
			wipe_out
		end


	TRAFFIC_VIEW_CONTAINER [G, TRAFFIC_3D_RENDERABLE [G]]

create
	make_as_child

feature -- Initialization

	make_as_child (a_parent: TE_3D_NODE) is
			-- Set `Current' as child of `a_parent'.
		do
			Precursor (a_parent)
		end

feature -- Access

	count: INTEGER is
			-- Number of items in list
		do
			Result := children.count
		end

	item_for_iteration: TRAFFIC_3D_RENDERABLE [G] is
			-- Item at internal cursor position
		do
			Result := children.item_for_iteration
		end

	item (i: INTEGER_32): TRAFFIC_3D_RENDERABLE [G]
			-- Item at index `i'
		do
			Result := children.item (i)
		end

feature -- Status report

	has (v: TRAFFIC_3D_RENDERABLE [G]): BOOLEAN
			-- Does list include `v'?
		do
			Result := children.has (v)
		end

	is_empty: BOOLEAN
			-- Is container empty?
		do
			Result := children.is_empty
		end

	after: BOOLEAN is
			-- Is there no item at internal cursor position?
		do
			Result := children.after
		end

	first: TRAFFIC_3D_RENDERABLE [G] is
			-- First item in list
		do
			Result := children.first
		end

	last: TRAFFIC_3D_RENDERABLE [G]
			-- Last item in list
		do
			Result := children.last
		end

feature -- Insertion

	put_first (v: TRAFFIC_3D_RENDERABLE [G])
			-- Add `v' to beginning of list.
			-- Do not move cursors.
		do
			children.force_first (v)
			v.set_parent (Current)
		end

	put_last (v: TRAFFIC_3D_RENDERABLE [G]) is
			-- Add `v' to end of list.
			-- Do not move cursors.
		do
			children.force_last (v)
			v.set_parent (Current)
		end

	replace (v: TRAFFIC_3D_RENDERABLE [G]; i: INTEGER) is
			-- Replace item at index `i' by `v'.
			-- Do not move cursors.
		do
			children.item (i).set_parent (Void)
			children.replace (v, i)
			v.set_parent (Current)
		end

	put (v: TRAFFIC_3D_RENDERABLE [G]; i: INTEGER) is
			-- Add `v' at `i'-th position.
			-- Do not move cursors.
		do
			children.force (v, i)
			v.set_parent (Current)
		end

feature -- Removal

	remove_first
			-- Remove item at beginning of list.
			-- Move any cursors at this position forth.
		do
			children.first.set_parent (Void)
			children.remove_first
		end

	remove_last
			-- Remove item at end of list.
			-- Move any cursors at this position forth.
		do
			children.last.set_parent (Void)
			children.remove_last
		end

	remove (i: INTEGER_32)
			-- Remove item at `i'-th position.
			-- Move any cursors at this position forth.
		do
			children.item (i).set_parent (Void)
			children.remove (i)
		end

	delete (v: TRAFFIC_3D_RENDERABLE [G])
			-- Remove all occurrences of `v'.
			-- Move all cursors off.
		do
			v.set_parent (Void)
			children.delete (v)
		end

	wipe_out
			-- Remove all items from list.
			-- Move all cursors off.
		do
			from
				children.start
			until
				children.off
			loop
				children.item_for_iteration.set_parent (Void)
				children.forth
			end
			children.wipe_out
		end

feature -- Cursor movement

	start
			-- Move internal cursor to first position.
		do
			children.start
		end

	forth is
			-- Move internal cursor to next position.
		do
			children.forth
		end

--feature -- Access

--	child_for_item (an_item: G): TRAFFIC_3D_RENDERABLE [G] is
--			-- Graphical representation for `an_item'
--		require
--			an_item_not_void: an_item /= Void
--			has_child: has_child (an_item)
--		local
--			r: TRAFFIC_3D_RENDERABLE [G]
--		do
--			from
--				children.start
--			until
--				children.off or Result /= Void
--			loop
--				r ?= children.item
--				if r /= Void and then r.item = an_item then
--					Result := r
--				end
--				children.forth
--			end
--		ensure
--			Result_not_void: Result /= Void
--			same_moving: Result.item = an_item
--		end

--feature -- Status report

--	has_child (an_item: G): BOOLEAN is
--			-- Does `an_item' have a graphical representation?
--		require
--			an_item_not_void: an_item /= Void
--		local
--			r: TRAFFIC_3D_RENDERABLE [G]
--		do
--			from
--				children.start
--			until
--				children.off or Result
--			loop
--				r ?= children.item
--				if r /= Void and then r.item = an_item then
--					Result := True
--				end
--				children.forth
--			end
--		end

feature {NONE} -- Implementation

	internal_children: DS_ARRAYED_LIST [TRAFFIC_3D_RENDERABLE [G]]
			-- Children
end
