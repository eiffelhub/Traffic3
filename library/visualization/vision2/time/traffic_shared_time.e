note
	description: "Singleton that simulates time of the day"
	date: "$Date$"

class
	TRAFFIC_SHARED_TIME

feature -- Access

	time: TRAFFIC_TIME 
			-- Time singleton that simulates a day
		once
			create {TRAFFIC_VISION2_TIME} Result.make_with_speedup (2)
		ensure
			Result_exists: Result /= Void
		end

end
