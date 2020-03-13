indexing
	description: "The Sun"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_SUN
inherit
	DOUBLE_MATH
		export {NONE} all end

	MATH_CONST
		export
			{NONE} all
			{ANY} pi
		end

	TRAFFIC_SHARED_TIME


create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		do
			theta := 0.6
			phi := 1.0
			radius := 20000.0
			time.add_callback_procedure (agent update)
		ensure
--			coordinates_initialized : (theta = 0.6) and (phi = 1.0) and (radius = 50.0)
		end


feature -- Access

	theta: DOUBLE
			-- Longitude (rad)

	phi: DOUBLE
			-- Colatitude (rad)

	radius: DOUBLE
			-- Radius

	position : GL_VECTOR_3D[DOUBLE] is
			-- Position of the sun in carthesian coordinates
		do
			create Result.make_xyz (radius*sine(theta)*cosine(phi),
									radius*sine(theta)*sine(phi),
									radius*cosine(theta))
		ensure
			result_set: Result /= Void
		end

feature -- Element change

	set_theta (new_theta: DOUBLE) is
			-- Set longitude to `new_theta'.
		require
			new_theta_valid: new_theta >= 0 and new_theta < 2*pi
		do
			theta := new_theta
		ensure
			new_theta_set: theta = new_theta
		end

	set_phi (new_phi: DOUBLE) is
			-- Set colatitude to `new_phi'.
		require
			new_phi_valid: new_phi >= 0 and new_phi < pi
		do
			phi := new_phi
		ensure
			new_phi_set: phi = new_phi
		end

	set_radius(new_radius: DOUBLE) is
			-- Set radius to `new_radius'.
		require
			new_radius_valid: new_radius >= 0
		do
			radius := new_radius
		ensure
			new_radius_set: radius = new_radius
		end

	update is
			-- Set Coordinates corresponding to time
		require
			time_exists: time /= Void
		do
			theta := (3*pi/2.0 + (2.0*pi*(time.actual_time.hour*3600.0 + time.actual_time.minute*60.0 + time.actual_time.second))/(24.0*60.0*60.0))
			if theta >= 2*pi then
				theta := theta - 2*pi
			end
		ensure
			theta_valid: theta >= 0 and theta < 2*pi
		end

invariant
	longitude_valid: theta >= 0 and theta < 2*pi
	colatitude_valid: phi >= 0 and phi < pi
	radius_valid: radius >= 0
end
