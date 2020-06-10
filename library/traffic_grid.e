note
	description: "Grid that stores what objects occupy positions on the city"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_GRID

create
	make

feature {NONE} -- Initialization

	make (a_length: INTEGER; a_center: TRAFFIC_POINT; a_radius: REAL_64)
			-- Initialize the grid with `a_length'*`a_length' number of fields and coordinate transformations
			-- such that `a_center' is in the middle of the grid.
		require
			a_length_valid: a_length > 0
			a_center_exists: a_center /= Void
			a_radius_valid: a_radius > 0
		do
			create boolean_grid.make (a_length, a_length)
			center := a_center
			radius := a_radius
		ensure
			a_length_set: boolean_grid.width = a_length and boolean_grid.height = a_length
			a_center_set: center = a_center
			a_radius_set: radius = a_radius
		end

feature -- Access

	boolean_grid: ARRAY2[BOOLEAN]
			-- Two dimensional boolean grid over plane with size `Grid_size'. Used for random building placement.
			--	True means the cell is occupied
			--	False means the cell is free

	radius: REAL_64
			-- Radius around which the city is located

	center: TRAFFIC_POINT
			-- Center of the city

feature -- Basic operations

	mark_polyline (a_list: DS_ARRAYED_LIST [TRAFFIC_POINT]; a_line_width: REAL_64; a_value: BOOLEAN)
			-- Mark grid cells for a polyline.
		require
			a_line_width_valid: a_line_width > 0
			a_list_valid: a_list /= Void and then a_list.count >= 2
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i >= a_list.count
			loop
				mark_line (a_list.item (i), a_list.item (i + 1), a_line_width, a_value)
				i := i + 1
			end
		end


	mark_line (p0, p1: TRAFFIC_POINT; a_line_width: REAL_64; a_value: BOOLEAN)
    		-- Mark grid cells along the line from `p0' to `p1' with `a_value' using a standard line drawing algorithm.
    	require
    		a_line_width_valid: a_line_width > 0
    		p0_valid: p0 /= Void
    		p1_valid: p1 /= Void
    		point_not_same: p0.distance (p1) > 0.0
    	local
	    	x0_local, y0_local, x1_local, y1_local: INTEGER
	        dx,dy: REAL_64
	        m, b: REAL_64
	        t: TUPLE [INTEGER, INTEGER]
		do
			t := grid_coordinate (p0)
			x0_local := t.integer_item (1)
			y0_local := t.integer_item (2)
			t := grid_coordinate (p1)
			x1_local := t.integer_item (1)
			y1_local := t.integer_item (2)
			dy := y1_local - y0_local
			dx := x1_local - x0_local
			mark_square_grid_coords (x0_local, y0_local, a_line_width, a_value)

			if dx.abs > dy.abs then
            	m := dy/dx					-- compute slope
            	b := y0_local - m*x0_local
	            	if dx < 0 then
	            		dx := -1.0
	            	else
	            		dx := 1.0
	            	end
            	from
            	until
            		x0_local = x1_local
            	loop
            		x0_local := x0_local + dx.rounded
            		y0_local := (m*x0_local + b).rounded
       				mark_square_grid_coords (x0_local, y0_local,a_line_width, a_value)

		        end
            else
            	if not (dy = 0) then
	            	m := dx/dy					-- compute slope
	            	b := x0_local - m*y0_local
		            	if dy < 0 then
		            		dy := -1.0
		            	else
		            		dy := 1.0
		            	end
	            	from
	            	until
	            		y0_local = y1_local
	            	loop
	            		y0_local := y0_local + dy.rounded
	            		x0_local := (m*y0_local + b).rounded
	            		mark_square_grid_coords (x0_local, y0_local,a_line_width, a_value)
	            	end
				end
        	end
   		 end


	mark_rectangle (a_center: TRAFFIC_POINT; a_width, a_breadth: REAL_64; a_value: BOOLEAN)
			-- Mark cells with `a_value' within rectangular area.
		require
			a_center_valid: a_center /= Void
			a_width_valid: a_width > 0.0
			a_breadth_valid: a_breadth > 0.0
		local
			nr_cells_in_x_direction:INTEGER
			nr_cells_in_y_direction:INTEGER
			i,j,k,l: INTEGER
			t: TUPLE[INTEGER, INTEGER]
		do
			nr_cells_in_x_direction := (a_width/(2*radius/boolean_grid.width)).ceiling
			nr_cells_in_y_direction := (a_breadth/(2*radius/boolean_grid.height)).ceiling
			t := grid_coordinate (a_center)
			boolean_grid.put (True, t.integer_item (1), t.integer_item (2))
			from
				i := t.integer_item (1) - (nr_cells_in_x_direction/2).floor
				j := t.integer_item (1) + (nr_cells_in_x_direction/2).floor
			until
				i > j
			loop
				from
					k := t.integer_item (2) - (nr_cells_in_y_direction/2).floor
					l := t.integer_item (2) + (nr_cells_in_y_direction/2).floor
				until
					k > l
				loop
					if 1 <= i and then i <= boolean_grid.width and then 1 <= k and then k <= boolean_grid.height then
						boolean_grid.put (True, i , k)
					end
					k := k + 1
				end
				i := i + 1
			end
		end

feature -- Status report

	has_rectangle_collision (a_center: TRAFFIC_POINT; a_width, a_breadth: REAL_64): BOOLEAN
			-- Does the rectangle with `a_center', `a_width' and `a_breadth' have any collision with marked grid cells?
		require
			a_center_valid: a_center /= Void
			a_width_valid: a_width > 0.0
			a_breadth_valid: a_breadth > 0.0
		local
			i,j,k,l: INTEGER
			res: BOOLEAN
			t, s: TUPLE [INTEGER, INTEGER]
		do
			res:= False
			t := grid_coordinate (create {TRAFFIC_POINT}.make (a_center.x - a_width/2, a_center.y - a_breadth/2))
			s := grid_coordinate (create {TRAFFIC_POINT}.make (a_center.x + a_width/2, a_center.y + a_breadth/2))
			from
				i := t.integer_item (1)-- - (nr_cells_in_x_direction/2).floor
				j := s.integer_item (1)-- + (nr_cells_in_x_direction/2).floor
			until
				i > j or res
			loop
				from
					k := t.integer_item (2)-- - (nr_cells_in_y_direction/2).floor
					l := s.integer_item (2)-- + (nr_cells_in_y_direction/2).floor
				until
					k > l or res
				loop
					if 1 <= i and then i <= boolean_grid.width and then 1 <= k and then k <= boolean_grid.height then
						if boolean_grid [i, k] then
							res := True
						end
					else
						res:= True   -- building not completely on plane
					end
					k := k + 1
				end
				i := i + 1
			end
			Result := res
		end

	has_square_collision (a_center: TRAFFIC_POINT; a_diagonal: REAL_64): BOOLEAN
			-- Does the square with `a_center' and `a_diagonal' have any collision with marked grid cells?
		require
			a_center_valid: a_center /= Void
			a_diagonal_valid: a_diagonal > 0.0
		local
			nr_cells_to_cover_diagonal:INTEGER
			i,j,k,l: INTEGER
			res: BOOLEAN
			t: TUPLE [INTEGER, INTEGER]
		do
			res := False
			t := grid_coordinate (a_center)
			nr_cells_to_cover_diagonal := (a_diagonal/(2*radius/boolean_grid.width)).ceiling
			if boolean_grid [t.integer_item (1), t.integer_item (2)] then
				res := True
			end
			from
				i := t.integer_item (1) - (nr_cells_to_cover_diagonal/2).floor
				j := t.integer_item (1) + (nr_cells_to_cover_diagonal/2).floor
			until
				i > j or res
			loop
				from
					k := t.integer_item (2) - (nr_cells_to_cover_diagonal/2).floor
					l := t.integer_item (2) + (nr_cells_to_cover_diagonal/2).floor
				until
					k > l or res
				loop
					if 1 <= i and i <= boolean_grid.width and 1 <= k and k <= boolean_grid.height then
						if boolean_grid [i, k] then
							res := True
						end
					else
						res := True  -- building not completely on plane
					end
					k := k + 1
				end
				i := i + 1
			end
			Result := res
		end

feature -- Conversion

	grid_coordinate (a_coord: TRAFFIC_POINT): TUPLE [INTEGER,INTEGER]
			-- Grid coordinate for city coordinate `a_coord'
		local
			x, y: INTEGER
		do
			x := ((a_coord.x - center.x + radius)/(2*radius/boolean_grid.width)).ceiling
			y := ((a_coord.y - center.y + radius)/(2*radius/boolean_grid.height)).ceiling
			if x > boolean_grid.width then
				x := boolean_grid.width
			end
			if x < 1 then
				x := 1
			end
			if y > boolean_grid.height then
				y := boolean_grid.height
			end
			if y < 1 then
				y := 1
			end
			Result := [x, y]
		ensure
			grid_coord_valid: 	Result.integer_item (1) >= 1 and Result.integer_item (1) <= boolean_grid.width and
								Result.integer_item (2) >= 1 and Result.integer_item (2) <= boolean_grid.height
		end

feature {NONE} -- Implementation

	mark_square_grid_coords (grid_x, grid_y:INTEGER; a_width:REAL_64; a_value: BOOLEAN)
			-- Mark cells with `a_value' within quadratic area where `grid_x', `grid_y'  a grid coordinate.
		require
			grid_x_valid: grid_x >= 1 and grid_x <= boolean_grid.width
			grid_y_valid: grid_y >= 1 and grid_y <= boolean_grid.height
		local
			nr_cells_to_cover_area: INTEGER
			start_x, end_x,start_y,end_y:INTEGER
		do
			if 1 <= grid_x and grid_x <= boolean_grid.width and 1 <= grid_y and grid_y <= boolean_grid.width then
				boolean_grid.put (a_value, grid_x, grid_y)
			end
			if  a_width > 0 then
				nr_cells_to_cover_area := (a_width/(radius*2/boolean_grid.width)).ceiling
				from
					start_x := grid_x - (nr_cells_to_cover_area/2).floor
					end_x := grid_x + (nr_cells_to_cover_area/2).floor
				until
					start_x > end_x
				loop
					from
						start_y := grid_y - (nr_cells_to_cover_area/2).floor
						end_y := grid_y + (nr_cells_to_cover_area/2).floor
					until
						start_y > end_y
					loop
						if 1 <= start_x and start_x <= boolean_grid.width and 1 <= start_y and start_y <= boolean_grid.height then
							boolean_grid.put (True, start_x , start_y)
						end
						start_y := start_y + 1
					end
					start_x := start_x + 1
				end
			end
		end

end
