note
	description: "[
			Sub pixmaps for use with EV_CANVAS not scaling.
			Therefore position is given in the center.
			]"
	status:	"See notice at end of class"
	author: "Till G. Bay"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.4 $"

class DRAWABLE_ICON inherit

	DRAWABLE_OBJECT

create

	make

feature -- Creation

	make (a_sub_pixmap: EV_PIXMAP; a_position: REAL_COORDINATE )
			-- Create a `a_sub_pixmap' at `a_position'.
		require
			a_sub_pixmap_not_void: a_sub_pixmap /= Void
			a_position_not_void: a_position /= Void
		do
			position:= a_position
			pixmap:= a_sub_pixmap
			set_color (create {EV_COLOR}.make_with_rgb (0.0, 0.0, 0.0))
			create area.make (0, 0, pixmap.width, pixmap.height)
			is_shown := True
		ensure
			position_set: position = a_position
			pixmap_set: pixmap = a_sub_pixmap
			shown: is_shown
		end

feature -- Element change

	set_position (a_coordinate: REAL_COORDINATE)
			-- Set `position' to `a_coordinate'.
		require
			a_coordinate_exists: a_coordinate /= Void
		do
			create position.make (a_coordinate.x, a_coordinate.y)
			invalidate
		ensure
			not_valid: not is_valid
			position_set: position.x = a_coordinate.x and position.y = a_coordinate.y
		end

feature -- Access

	position: REAL_COORDINATE
			-- Position of the icon

	pixmap: EV_PIXMAP
			-- The icon

	area: EV_RECTANGLE
			-- The area of the icon

	bounding_box : REAL_RECTANGLE
			-- The bounding box of the icon
		do
			create Result.make (position, create {REAL_COORDINATE}.make (position.x + pixmap.width, position.y + pixmap.height))
		end

feature {CANVAS} -- Display

	draw_object
			-- Draw the icon.
		local
			scaled_position : EV_COORDINATE
			coord: REAL_COORDINATE
		do
			create coord.make (position.x+pixmap.width/2, position.y-pixmap.height/2)
			scaled_position := real_to_integer_coordinate (coord)
			canvas.draw_sub_pixmap (scaled_position.x-(pixmap.width/2).floor, scaled_position.y-(pixmap.height/2).floor, pixmap, area)
		end

invariant

	position_not_void: position /= Void
	pixmap_not_void: pixmap /= Void
	area_not_void: area /= Void

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
