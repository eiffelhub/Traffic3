note
	description:
		"[
			Canvas with comfortable zooming and panning abilities.
		 ]"

	author: "Rolf Bruderer & Michela Pedroni, ETH Zurich"
	date: "$Date: 2004/10/20 10:03:03 $"
	revision: "$Revision: 1.6 $"

class ZOOMABLE_CANVAS inherit

	CANVAS
		redefine
			make,
			set_size
		end

create
	make

feature -- Canvas elements

	make
			-- Initialize.
		do
			Precursor
			set_zoom_limits (0.5, 2)
			zoom_factor := 1.0
			has_pending_redraw := false
			redraw_agent := agent redraw_now
			mouse_wheel_actions.extend (agent zoom)
			pan_agent := agent pan
			pointer_button_release_actions.extend (agent move_end)
			pointer_button_press_actions.extend (agent move_start)
			pointer_leave_actions.extend (agent release)
		end


	zoom_factor: REAL_64
			-- Zooming factor

	zoom_maximum: REAL_64
			-- Max zoom out factor

	zoom_minimum: REAL_64
			-- Max zoom in factor

	set_zoom_limits (min, max: REAL_64)
			-- Set the both zoom limits `zoom_minimum' and `zoom_maximum'.
		require
			min_smaller_than_max: min < max
			min_greater_than_zero: min > 0
		do
			zoom_minimum := min
			zoom_maximum := max
		end

	update_visible_area
			-- Updates the visible area according to `width', `height' and `zoom_factor'.
		local
			old_center: REAL_COORDINATE
		do
			old_center := visible_area.center

			-- Set visible area with `width' and `height'.
			visible_area.make (
				create {REAL_COORDINATE}.make(0.0, 0.0),
				create {REAL_COORDINATE}.make(width, height)
			)
			-- Zoom new visible area.
			visible_area.scale (zoom_factor)

			-- Ensure that center of zoomed new visible area is same as old visible area.			
			visible_area.up_by (old_center.y - visible_area.center.y)
			visible_area.right_by (old_center.x - visible_area.center.x)

			-- Redraw the canvas as soon as possible.
			redraw
		end

	zoom_in (zoom_factor_delta: REAL_64)
			-- Zoom in stepwise.
		do
			zoom_factor := (zoom_factor - zoom_factor_delta).max (zoom_minimum)
			update_visible_area
		end

	zoom_out (zoom_factor_delta: REAL_64)
			-- Zoom out stepwise.
		do
			zoom_factor := (zoom_factor + zoom_factor_delta).min (zoom_maximum)
			update_visible_area
		end

	go_right (pan_distance: REAL_64)
			-- Move right.
		do
			visible_area.left_by (pan_distance)
			redraw
		end

	go_left (pan_distance: REAL_64)
			-- Move left.	
		do
			visible_area.right_by (pan_distance)
			redraw
		end

	go_up (pan_distance: REAL_64)
			-- Move up.	
		do
			visible_area.down_by (pan_distance)
			redraw
		end

	go_down (pan_distance: REAL_64)
			-- Move down.	
		do
			visible_area.up_by (pan_distance)
			redraw
		end

	set_size (a_width, a_height: INTEGER)
			-- Assign `a_width' and `a_height' to `width' and `weight'.
			-- Keep `zoom_factor' and keep center position.
		do
			Precursor (a_width, a_height)
			update_visible_area
		end

feature {NONE} -- Implementation


	zoom  (y: INTEGER)
			-- Zoom in or out.
		do
			if y > 0 then
				zoom_in (y * Zoom_factor_stepwise)
			elseif y < 0 then
				zoom_out (y * (-Zoom_factor_stepwise))
			end
		end

	move_start (x, y, b: INTEGER; x_t, y_t, p: REAL_64;
			scr_x, scr_y: INTEGER)
			-- Mouse down on the canvas (evt. start of moving).
			-- (For an explanation of arguments look at
			-- EV_POINTER_BUTTON_ACTION_SEQUENCE).
		local
			pt: REAL_COORDINATE
		do
			if b = 1 then
				pointer_motion_actions.extend (pan_agent)

				create pt.make (x, y)
				last_cursor_position := pt
			end
		end

	pan_agent: PROCEDURE [ANY, TUPLE [INTEGER_32, INTEGER_32, REAL_64, REAL_64, REAL_64, INTEGER_32, INTEGER_32]]

	pan (x, y: INTEGER_32; x_t, y_t, p: REAL_64; scr_x, scr_y: INTEGER_32)
			--
		local
			pt: REAL_COORDINATE
			xdiff: REAL_64
			ydiff: REAL_64
		do
			create pt.make (x, y)
			if last_cursor_position /= Void then
				xdiff := (last_cursor_position.x - pt.x)*zoom_factor
				ydiff := (last_cursor_position.y - pt.y)*zoom_factor
				if xdiff /= 0 or ydiff /= 0 then
					go_down (-ydiff)
					go_left (xdiff)
					redraw
				end
			end
			last_cursor_position := pt
		end


	last_cursor_position: REAL_COORDINATE

	move_end (x, y, b: INTEGER; x_t, y_t, p: REAL_64;
			scr_x, scr_y: INTEGER)
			-- Release mouse pointer.
			-- (For an explanation of arguments look at
			-- EV_POINTER_BUTTON_ACTION_SEQUENCE.)
		local
			pt: REAL_COORDINATE
			xdiff: REAL_64
			ydiff: REAL_64
		do
			create pt.make (x, y)
			if last_cursor_position /= Void and (b = 1)  then
				xdiff := last_cursor_position.x - pt.x
				ydiff := last_cursor_position.y - pt.y
				if xdiff /= 0 or ydiff /= 0 then
					go_down (ydiff)
					go_left (xdiff)
					redraw
				end
			end
			last_cursor_position := Void --main_window.client_to_map_coordinates (x, y)
			pointer_motion_actions.prune (pan_agent)
		end

	release
			-- Leave application window.
		do
			last_cursor_position := Void
			pointer_motion_actions.prune (pan_agent)
		end

	Zoom_factor_stepwise: REAL_64 = 0.05
			-- Stepwise zoom factor

end -- class SPECIAL_CANVAS

--|--------------------------------------------------------
--| This file is Copyright (C) 2004 by ETH Zurich.
--|
--| For questions, comments, additions or suggestions on
--| how to improve this package, please write to:
--|
--|     Michela Pedroni <michela.pedroni@inf.ethz.ch>
--| 	Rolf Bruderer <bruderer@computerscience.ch>
--|
--|--------------------------------------------------------
