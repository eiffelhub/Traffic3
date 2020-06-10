note
	description :"Buildings for the traffic library"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_BUILDING

inherit

	ANY

	DOUBLE_MATH
		export {NONE} all end

	MATH_CONST
		export {NONE} all end

	TRAFFIC_CITY_ITEM
		rename
			highlight as spotlight,
			unhighlight as unspotlight,
			is_highlighted as is_spotlighted
		end

feature {NONE} -- Initialization

	make_new (a_width, a_depth, a_height: REAL_64; a_center: TRAFFIC_POINT)
			-- Initialize `Current' with size and `a_center'.
		require
			size_valid: a_width > 0.0 and a_height > 0.0 and a_depth > 0.0
			center_valid: a_center /= Void
		do
			width := a_width
			height := a_height
			depth := a_depth
			center := a_center
			create changed_event
		ensure
			size_set: width = a_width and height = a_height and depth = a_depth
			center_set: center = a_center
		end

feature -- Status report

	is_villa: BOOLEAN
			-- Is the building a villa?

	is_apartment_building: BOOLEAN
			-- Is the building an apartment house?

	is_skyscraper: BOOLEAN
			-- Is the building a skyscraper?

	is_landmark: BOOLEAN
			-- Is the building a landmark?

	is_insertable (a_city: TRAFFIC_CITY): BOOLEAN
			-- Is `Current' insertable into `a_city'?
			-- (All nodes need to be insertable. See `TRAFFIC_NODE is_insertable' for requirements.)
		do
			Result := True
		end

	is_removable: BOOLEAN
			-- Is `Current' removable from `city'?
		do
			Result := True
		end

feature -- Access

	center: TRAFFIC_POINT
			-- Center of the building

	angle: REAL_64
			-- Angle in degrees

	height: REAL_64
			-- Height of the building

	depth: REAL_64
			-- Breath of the building

	width: REAL_64
			-- Width of the buiding

	description: STRING
			-- Description

	corner_1: TRAFFIC_POINT
			-- Lower left corner of the building
		do
			create Result.make (center.x - width/2, center.y - depth/2)
			Result := Result.rotation (center, angle)
		ensure
			Result_exists: Result /= Void
		end

	corner_2: TRAFFIC_POINT
			-- Lower right corner of the building
		do
			create Result.make (center.x + width/2, center.y - depth/2)
			Result := Result.rotation (center, angle)
		ensure
			Result_exists: Result /= Void
		end

	corner_3: TRAFFIC_POINT
			-- Upper right corner of the building
		do
			create Result.make (center.x + width/2, center.y + depth/2)
			Result := Result.rotation (center, angle)
		ensure
			Result_exists: Result /= Void
		end

	corner_4: TRAFFIC_POINT
			-- Upper left corner of the building
		do
			create Result.make (center.x - width/2, center.y + depth/2)
			Result := Result.rotation (center, angle)
		ensure
			Result_exists: Result /= Void
		end

feature -- Status report

	contains_point(a_x: REAL_64; a_y: REAL_64): BOOLEAN
			-- Is point (`a_x', `a_y') inside building?
		local
			delta_x1: REAL_64
			delta_x2: REAL_64
		do

			Result := false

			if angle/=0 and angle/=90 then
				delta_x1 := dabs((a_y-corner_2.y)/tangent(pi/2+angle*pi/180))
				delta_x2 := dabs((corner_4.y-a_y)/tangent(pi/2+angle*pi/180))
			else
				delta_x1 := 0
				delta_x2 := 0
			end

			if (a_y >= corner_3.y - 0.1) and (a_y <= corner_1.y + 0.1) then
				if (a_x <= corner_2.x-delta_x1+0.1) and (a_x >= corner_4.x+delta_x2 - 0.1) then
					Result := true
				end
			end

		end

feature -- Element change

	set_size (a_width, a_height, a_depth: REAL_64)
			-- Set `width' to `a_width', `height' to `a_height', and `depth' to `a_depth'.
		require
			size_valid: a_width > 0.0 and a_height > 0.0 and a_depth > 0.0
		do
			width := a_width
			height := a_height
			depth := a_depth
		ensure
			size_set: width = a_width and height = a_height and depth = a_depth
		end

	set_description (a_description: STRING)
			-- Set description to `a_description'.
		require
			a_description_valid: a_description /= void
		do
			description := a_description
			changed_event.publish ([])
		ensure
			description_set: description = a_description
		end

	set_angle (an_angle: REAL_64)
			-- Set angle to `a_angle'.
		require
			angle_valid: an_angle >= -70 and an_angle <=70
		do
			angle := an_angle
			changed_event.publish ([])
		ensure
			angle_set: angle = an_angle
		end

	 set_center (a_center: TRAFFIC_POINT)
	 		-- Set `center' to `a_center'.
	 	require
	 		a_center_valid: a_center /= Void
	 	do
	 		center := a_center
			changed_event.publish ([])
		ensure
			center_set: center = a_center
	 	end

invariant

	angle_valid: angle >= -70 and angle <= 70
	breadth_valid: depth > 0
	width_valid: width > 0
	heigth_valid: height > 0
	is_one_type: is_villa xor is_apartment_building xor is_skyscraper xor is_landmark

end
