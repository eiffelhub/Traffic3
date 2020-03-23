note
	description: "Container for vision2 city item views"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_VS_VIEW_CONTAINER [G]

inherit

	TRAFFIC_VIEW_CONTAINER [G, TRAFFIC_VS_VIEW [G]]
		undefine
			show,
			hide
		end

	DRAWABLE_OBJECT_CONTAINER [TRAFFIC_VS_VIEW [G]]

create
	make

end
