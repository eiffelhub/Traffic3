note
	description: "Deferred class for moving items in the city"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_MOVING

inherit

	DOUBLE_MATH
		export {NONE} all end

	TRAFFIC_SHARED_TIME

	TRAFFIC_CITY_ITEM

feature -- Access

	location: TRAFFIC_POINT
			-- Current location

	origin: TRAFFIC_POINT
			-- Origin location

	destination: TRAFFIC_POINT
			-- Destination location

	speed: REAL_64
			-- Speed in m/s

	angle_x: REAL_64
			-- Angle in respect to the x-axis

feature -- Status report

	is_reiterating: BOOLEAN
			-- Does it turn around if the destination is reached?

	is_traveling_back: BOOLEAN
			-- Is 'Current' traveling back through polypoints?

	has_finished: BOOLEAN
			-- Has it finished his journey?	

	is_marked: BOOLEAN
			-- Is the moving marked, highlighted?

feature -- Basic operations

	start
			-- Start taking a tour.
		do
			time.add_callback_tour (agent advance)
		end

feature -- Element change

	set_speed (a_speed: REAL_64)
			-- Set the speed to 'a_speed'.
		require
			a_speed_valid: a_speed >= 0
		do
			speed := a_speed
		ensure
			speed_set: speed = a_speed
		end

	set_reiterate (a_boolean: BOOLEAN)
			-- Set the moving reiterating his itinerary.
		do
			is_reiterating := a_boolean
		ensure
			reiterating_set: is_reiterating = a_boolean
		end

feature {NONE} -- Implementation

	advance
			-- Move from origin to destination.
		local
			direction: TRAFFIC_POINT
			diff: REAL_64
		do
			direction := destination - origin

			if not has_finished and last_move_time /= Void then
				current_move_time.make_by_fine_seconds (time.actual_time.fine_seconds)
				if not current_move_time.is_equal (last_move_time) then
					diff := (time.duration (last_move_time, current_move_time).fine_seconds_count)*speed/time.default_scale_factor
					if ((location.x - destination.x).abs < diff) and ((location.y - destination.y).abs < diff) or direction.length <= 0 then
						move_next
						update_angle
					else
						location := location + (direction / direction.length) * diff
					end


					last_move_time.make_by_fine_seconds (time.actual_time.fine_seconds)
				end
			else
				create last_move_time.make_by_fine_seconds (time.actual_time.fine_seconds)
				create current_move_time.make_by_fine_seconds (time.actual_time.fine_seconds)
			end
		end

	move_next 
			--  Move to following position
		require
			poly_cursor_valid: not poly_cursor.after and not poly_cursor.before
			not_finished: not has_finished
		deferred
		ensure
			origin /= Void
			location /= Void
			destination /= Void
		end

	update_angle
			-- Set the angles to the x- and y-axis respectively.
		local
			x_difference, y_difference, hypo, quad: REAL_64
		do
			-- as the x-axis is turned by 180° we have to take this into account
			-- we need the x- and the y difference to calculate the norm
			x_difference := destination.x - origin.x
			y_difference := destination.y - origin.y
			hypo := sqrt ((x_difference * x_difference) + (y_difference * y_difference))

			if hypo /= 0 then
				-- arc_sine in radian
				quad := 0
				angle_x := arc_sine (x_difference/hypo)
				if  (x_difference >= 0) and (y_difference >= 0) then
					angle_x := arc_sine (x_difference/hypo)
					angle_x := pi + angle_x
				elseif (x_difference < 0) and (y_difference >= 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
					angle_x := pi - angle_x
				elseif (x_difference < 0) and (y_difference < 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
				elseif (x_difference >= 0) and (y_difference < 0) then
					x_difference := x_difference.abs
					y_difference := y_difference.abs
					angle_x := arc_sine (x_difference/hypo)
					angle_x := 2*pi - angle_x
				end
			end
		end


feature {NONE} -- Implementation

	poly_cursor: DS_ARRAYED_LIST_CURSOR [TRAFFIC_POINT]
			-- Cursor that guides the moving object

	last_move_time: TIME
			-- Time of the last move

	current_move_time: TIME
			-- Now (when a step is taken)

invariant
	origin_exists: origin /= Void
	destination_exists: destination /= Void
	location_exists: location /= Void
	speed_valid: speed >= 0
	poly_cursor_exists: poly_cursor /= Void
	poly_cursor.container.count >= 2
end

