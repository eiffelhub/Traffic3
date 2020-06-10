note
	description: "[
			Graphical picture stored as a two dimensional map of pixels.
		 	Can be zoomed, panned, modified and displayed.
		 	]"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/08/25 12:03:42 $"
	revision: "$Revision: 1.3 $"

class CANVAS

inherit

	EV_PIXMAP

create

	make

feature -- Creation

	make
			-- Create a new canvas.
		local
			figure_world : EV_FIGURE_WORLD
		do
			default_create
			create visible_area.make (
				create {REAL_COORDINATE}.make(0.0,0.0),
				create {REAL_COORDINATE}.make(1.0,1.0)
			)
			create figure_world
			create object_list.make
			create projector.make (figure_world,Current)
		end

feature -- Access

	object_list: DS_LINKED_LIST [DRAWABLE_OBJECT]
			-- The list of objects to draw

feature -- Display

	set_visible_area (an_area: like visible_area)
			-- Replace `visible_area' with `an_area'.
		do
			visible_area := an_area
		ensure
			new_visible_area: visible_area = an_area
		end

	draw_all_items (objects_to_draw: like object_list)
			-- Draw all `objects_to_draw'
		require
			objects_to_draw_not_void: objects_to_draw /= Void
		do
			clear
			object_list:= objects_to_draw
			from
				object_list.start
			until
				object_list.off
			loop
				draw_item(object_list.item_for_iteration)
				object_list.forth
			end
		end

	redraw_now
			-- Redraw all items on `Current'.
		do
			clear
			if object_list /= Void then
				from
					object_list.start
				until
					object_list.off
				loop
					draw_item(object_list.item_for_iteration)
					object_list.forth
				end
			end
			has_pending_redraw := false
			(create {EV_ENVIRONMENT}).application.remove_idle_action (redraw_agent)
		end

	redraw
			-- Redraw the canvas as soon as possible.
		do
			if not has_pending_redraw then
				(create {EV_ENVIRONMENT}).application.add_idle_action (redraw_agent)
				has_pending_redraw := true
			end
		ensure
			redraw_pending: has_pending_redraw
		end

feature -- Queries

	visible_area : REAL_RECTANGLE
			-- The visible_area

	projector : EV_PIXMAP_PROJECTOR
			-- A global projector for the pixmap, usable for figures

feature {NONE} -- Implementation

	draw_item (an_item: DRAWABLE_OBJECT)
			-- Draw `an_item'.
		require
			an_item_not_void: an_item /= Void
		do
			if
				an_item.bounding_box.intersects (visible_area)
			then
				an_item.draw (Current)
			end
		end

	has_pending_redraw : BOOLEAN
			-- Is there any pending redraw?

	redraw_agent: PROCEDURE [ANY, TUPLE]
			-- Redraw agent to redraw the canvas when idle

invariant

--	visible_area_set: visible_area /= Void

end

--|--------------------------------------------------------
--| This file is Copyright (C) 2003 by ETH Zurich.
--|
--| For questions, comments, additions or suggestions on
--| how to improve this package, please write to:
--|
--|     Till G. Bay <tillbay@student.ethz.ch>
--|
--|--------------------------------------------------------
