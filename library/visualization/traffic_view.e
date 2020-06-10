note
	description: "View for a city item"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_VIEW [G]

feature -- Initialization

	make (a_item: G) 
			-- Set `item' to `a_item'.
		require
			a_item_exists: a_item /= Void
		deferred
		ensure
			item_set: item = a_item
			is_shown: is_shown
			not_highlighted: not is_highlighted
		end

feature -- Access

	item: G
			-- Item the view represents

	color: TRAFFIC_COLOR
			-- Color for displaying

	highlight_color: TRAFFIC_COLOR
			-- Highlight color

feature -- Status setting

	set_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		deferred
		end

	set_highlight_color (a_color: TRAFFIC_COLOR)
			-- Set the color of the view to `a_color'.
		deferred
		end

feature -- Basic operations

	update
			-- Update `Current' to reflect changes in `item'.
		deferred
		end

	highlight
			-- Highlight the view.
		deferred
		ensure
			highlighted: is_highlighted
		end

	unhighlight
			-- Unhighlight the view.
		deferred
		ensure
			not_highlighted: not is_highlighted
		end

	hide
			-- Hide the view.
		deferred
		ensure
			hidden: not is_shown
		end

	show
			-- Show the view.
		deferred
		ensure
			shown: is_shown
		end

feature -- Status report

	is_highlighted: BOOLEAN
			-- Is the view highlighted?
		deferred
		end

	is_shown: BOOLEAN
			-- Is the view shown?
		deferred
		end

feature -- Element change

	set_item (a_item: like item)
			-- Set `item' to `a_item'.
		require
			a_item_exists: a_item /= Void
		do
			item := a_item
		ensure
			item_set: item = a_item
		end

end
