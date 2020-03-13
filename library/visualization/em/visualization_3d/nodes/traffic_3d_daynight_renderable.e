indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_3D_DAYNIGHT_RENDERABLE [G]

inherit
	TRAFFIC_3D_RENDERABLE [G]
		rename
			make as make_with_item_orig
		redefine
			render_node
		end

	TRAFFIC_SHARED_TIME

create
	make_with_item

feature -- Initialization

	make_with_item (a_item: G; a_day_graphical, a_night_graphical: TE_3D_NODE) is
			-- Initialize.
		require
			a_item_not_void: a_item /= Void
			a_day_graphical_not_empty: a_day_graphical /= Void
			a_night_graphical_not_empty: a_night_graphical /= Void
		do
			make_with_item_orig (a_item)
			day_graphical := a_day_graphical
			day_graphical.set_as_child_of (Current)

			night_graphical := a_night_graphical
			night_graphical.set_as_child_of (Current)
--			day_graphical.transform.set_scaling (50, 50, 50)
--			night_graphical.transform.set_scaling (50, 50, 50)

			-- TODO: randomize
			create night_start.make (19, 0, 0)
			create day_start.make (6, 0, 0)
		end

feature -- Access

	day_graphical: TE_3D_NODE

	night_graphical: TE_3D_NODE

	night_start: TIME

	day_start: TIME

feature -- Basic operations

	render_node is
			-- Update the position before the node is rendered.
		local
			is_night: BOOLEAN
		do
			if night_start < day_start then
				if time.actual_time > night_start and time.actual_time < day_start then
					is_night := True
				else
					is_night := False
				end
			else
				if time.actual_time > day_start and time.actual_time < night_start then
					is_night := False
				else
					is_night := True
				end
			end
			if is_night then
				day_graphical.disable_hierarchy_renderable
				night_graphical.enable_hierarchy_renderable
			else
				night_graphical.disable_hierarchy_renderable
				day_graphical.enable_hierarchy_renderable
			end
		end

end
