indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_2D_VIEW [G]

inherit

	TRAFFIC_VIEW [G]

	EM_DRAWABLE

feature -- Status report

	is_highlighted: BOOLEAN
			-- Is the place view highlighted?

	is_shown: BOOLEAN
			-- Is the place view shown?
		do
			Result := is_visible
		end

feature -- Element change

	show is
			-- Show the renderable.
		do
			set_visible (True)
		end

	hide is
			-- Hide the renderable.
		do
			set_visible (False)
		end

end
