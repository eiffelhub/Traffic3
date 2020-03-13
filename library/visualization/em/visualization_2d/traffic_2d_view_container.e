indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_2D_VIEW_CONTAINER [G]

inherit

	TRAFFIC_VIEW_CONTAINER [G, TRAFFIC_2D_VIEW [G]]
		undefine
			is_equal,
			copy
		end

	EM_DRAWABLE_CONTAINER [TRAFFIC_2D_VIEW [G]]
	 	rename
	 		extend as put_last,
	 		extend_with_list as extend
	 	end

create
	make

end
