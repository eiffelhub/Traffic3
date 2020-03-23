note
	description: "[
		Structures of walkable containers. Walkable means that every item of
		the container can be connected via a (directed or undirected) link to
		any other item.
		
		Traversal is done by moving	a cursor over the datastructure, looking 
		at a specific link towards another element of the container. 
		`left' and `right' will turn to	the next or previous available link, 
		`forth' will move to the target of the current link.

		While the number of items may be infinite, the number of
		links for any item has to be finite.
	]"
	author: "Bernd Schoeller (bernd@fams.de)"
	institution: "ETH Zurich"
	date: "$Date: 2005-05-25 15:06:13 +0200 (Ср, 25 май 2005) $"
	revision: "$Revision: 2 $"

deferred class
	WALKABLE [G]

inherit
	TRAVERSABLE [G]

feature -- Access

	target: G is
			-- Item at the target of the current edge
		require
			not_off: not off
			has_links: has_links
		deferred
		end

feature -- Measurement

	link_count: INTEGER is
			-- Number of links of item
		require
			not_off: not off
		deferred
		end

feature -- Status report

	has_links: BOOLEAN is
			-- Are there any links from item ?
		require
			not_off: not off
		deferred
		end

	exhausted: BOOLEAN is
			-- Last `left' or `right' turned to the first link ?
		require
			not_off: not off
		deferred
		ensure
			no_links_always_exhausted: not has_links implies exhausted
		end

	has_previous: BOOLEAN is
			-- Is there another node in the traversal history?
			-- Must be True in order to use the `back' command.
		deferred
		end

	is_first: BOOLEAN is
			-- Am I on the first link ?
		require
			not_off: not off
			has_links: has_links
		deferred
		end

feature -- Cursor movement

	left is
			-- Turn to the left link.
		require
			not_off: not off
			has_links: has_links
		deferred
		ensure
			went_around: is_first = exhausted
		end

	right is
			-- Turn to the right link.
		require
			not_off: not off
			has_links: has_links
		deferred
		ensure
			went_around: is_first = exhausted
		end

	turn_to (t: like target) is
			-- Try to turn the cursor towards `t'.
			-- If not possible, `exhausted' will be set
		require
			not_off: not off
		do
			from
				start
			until
				exhausted or else
				(object_comparison and equal(target,t)) or
				(not object_comparison and (target = t))
			loop
				left
			end
		ensure
			item_found: (not exhausted and not object_comparison) implies target = t
			object_found: (not exhausted and object_comparison) implies equal(target,t)
		end

	back is
			-- Move the cursor back to the previous node.
		require
			can_go_back: has_previous
		deferred
		end

	forth is
			-- Move the cursor to the target item by following the link that it is
			-- currently pointing to. If there are no links, the cursor
			-- will be moved to `off'.
		require
			not_off: not off
		deferred
		ensure
			moved_to_target: item = old target
			move_to_off: not old has_links = off
		end

	start is
			-- Turn to the first link.
		require else
			not_off: not off
		deferred
		ensure then
			pointing_to_first: has_links implies is_first
			exhausted_iff_no_links: not has_links = exhausted
		end

	search (a_item: G) is
			-- Move to the item equal to `a_item' are equal.
			-- (Reference or object equality)
			-- If no such position exists, `off' will be true
		deferred
		ensure
			item_found: (not off and not object_comparison) implies a_item = item
			object_found: (not off and object_comparison) implies equal(a_item,item)
		end

invariant

	zero_link_count: not off implies (has_links = (link_count > 0))

	exhausted_if_no_links: (not off and not has_links) implies exhausted

end -- class WALKABLE
