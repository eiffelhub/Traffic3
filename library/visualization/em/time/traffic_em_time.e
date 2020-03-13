indexing
	description: "This object represent the time in the city model"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_EM_TIME

inherit
	EM_TIME_SINGLETON
		undefine
			out
		end

	TRAFFIC_TIME

	EM_SHARED_SCENE
		undefine
			out
		end

create
	make_with_speedup

feature -- Basic operations

	start is
			-- Start to count the time at (0:0:0).
		do
			is_time_running := True
			running_scene.event_loop.update_event.subscribe (update_agent)
			real_ms_start := time.ticks
			simulated_ms_start := 0
		end

	pause is
			-- Pause the time count.
		do
			is_time_running := False
			running_scene.event_loop.update_event.unsubscribe (update_agent)
			simulated_ms_start := actual_time.seconds*1000
		end

	resume is
			-- Resume the paused time.
		do
			is_time_running := True
			running_scene.event_loop.update_event.subscribe (update_agent)
			real_ms_start := time.ticks
		end

	reset is
			-- Reset the time to (0:0:0).
		do
			actual_time.set_hour (0)
			actual_time.set_minute (0)
			actual_time.set_second (0)
			is_time_running := False
			real_ms_start := 0
			simulated_ms_start := 0
			running_scene.event_loop.update_event.unsubscribe (update_agent)
		end

feature{NONE} -- Implementation		

	update_time is
			-- Update the time count
		local
			real_ms: INTEGER
			sim_ms: INTEGER
		do
			if is_time_running then
				real_ms := time.ticks - real_ms_start
				sim_ms := speedup*real_ms + simulated_ms_start
				if sim_ms//1000 >= actual_time.seconds_in_day then
					real_ms_start := time.ticks
					sim_ms := (sim_ms//1000)\\actual_time.seconds_in_day
					simulated_ms_start := sim_ms
					actual_day := actual_day + 1
					actual_time.make_by_seconds (sim_ms)
				else
					actual_time.make_by_seconds (sim_ms//1000)
					actual_time.set_fractionals ((sim_ms\\1000)/1000)
				end
				call_tours
				call_procedure
			end
		end

end
