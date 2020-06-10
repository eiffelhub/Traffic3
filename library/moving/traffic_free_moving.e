note
	description: "Objects that can move around the city freely (do not need to travel on streets)"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_FREE_MOVING

inherit

	TRAFFIC_MOVING

create
	make_with_points

feature -- Initialization

	make_with_points (a_list: DS_ARRAYED_LIST [TRAFFIC_POINT]; a_speed: REAL_64)
			-- Set passengers route as `a_list' and speed to `a_speed' (in m/s).
			-- `a_list' is the list of the points where the passenger will go through.
		require
			a_list_not_void: a_list /= Void
			a_speed_not_negative: a_speed >= 0
		do
			create poly_cursor.make (a_list)
			poly_cursor.start
			location := poly_cursor.item
			move_next
			update_angle
			speed := a_speed
			create changed_event
		end


feature -- Status report

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
		do
			Result := True
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `a_city'?
		do
			Result := True
		end

feature {NONE} --Implementation

	move_next
			--  Move to following position
		do
			-- Set the locations to the corresponding ones of the line segment.
			origin :=  poly_cursor.item
			location := poly_cursor.item
			if is_traveling_back then
				poly_cursor.back
				if poly_cursor.before then
					is_traveling_back := False
					poly_cursor.forth
					move_next
				else
					destination := poly_cursor.item
				end
			elseif is_reiterating then
				poly_cursor.forth
				if poly_cursor.after then
					is_traveling_back := True
					poly_cursor.back
					move_next
				else
					destination := poly_cursor.item
				end
			else
				poly_cursor.forth
				if poly_cursor.after then
					has_finished := True
				else
					destination := poly_cursor.item
				end
			end
		end


end
