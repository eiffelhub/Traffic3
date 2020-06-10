note
	description: "This object represent the time in the city model"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TRAFFIC_TIME

inherit

	ANY
		redefine
			out
		end

feature -- Initialization

	make_with_speedup (a_speedup: INTEGER)
			-- Set `speedup' to `a_speedup'.
		require
			a_speedup_valid: a_speedup >= 1
		do
			create actual_time.make (0, 0, 0)
			speedup := a_speedup
			create all_procedures.make
			create all_tours.make

			actual_day := 0

			update_agent := agent update_time

		ensure
			speedup_set: speedup = a_speedup
		end

feature  -- Access

	actual_time: TIME
			-- Simulated time

	actual_day: INTEGER
			-- Simulated days since time counting started

	speedup: INTEGER
			-- Speedup to let the time run faster than the original time

	duration (a_start_time, a_end_time: like actual_time): TIME_DURATION
			-- Duration from `a_start_time' until `a_time2'.
			-- Takes into account midnight.
		require
			both_exist: a_start_time /= Void and a_end_time /= Void
		do
			if a_end_time >= a_start_time then
				create Result.make_by_fine_seconds (a_end_time.fine_seconds - a_start_time.fine_seconds)
			else
				create Result.make_by_fine_seconds (a_start_time.seconds_in_day - (a_start_time.fine_seconds - a_end_time.fine_seconds))
			end
		ensure
			Result_exists: Result /= Void
			Result_positive_or_zero: Result.is_positive or Result.is_zero
		end

feature -- Status report

	is_time_running: BOOLEAN
			-- Is the time running?

feature -- Basic operations

	set_speedup (a_speedup: INTEGER)
			-- Set `speedup' to `a_speedup'.
		require
			a_speedup_valid: a_speedup >= 1
		do
			if is_time_running then
				pause
				speedup := a_speedup
				resume
			else
				speedup := a_speedup
			end
		ensure
			speedup_set: speedup = a_speedup
		end

	start
			-- Start to count the time at (0:0:0).
		require
			not is_time_running
		deferred
		ensure
			is_time_running
		end

	pause
			-- Pause the time count.
		require
			is_time_running
		deferred
		ensure
			not is_time_running
		end

	resume
			-- Resume the paused time.
		require
			not is_time_running
		deferred
		ensure
			is_time_running
		end

	reset
			-- Reset the time to (0:0:0).
		deferred
		ensure
			is_time_running = False
			actual_time.hour = 0
			actual_time.minute = 0
			actual_time.second = 0
		end

	set (a_hour, a_minute, a_second: INTEGER)
			-- Sets the time to (`a_hour':`a_minute':`a_second').
		require
			valid_time: a_hour >=0 and a_minute >=0 and a_second >=0
		do
			actual_time.set_hour (a_hour)
			actual_time.set_minute (a_minute)
			actual_time.set_second (a_second)
			simulated_ms_start := actual_time.seconds*1000
		end

feature -- Constants

	Default_scale_factor: REAL_64 = 5.52

feature -- Output

	out: STRING
			-- Output
		do
			Result := actual_time.hour.out + ":" + actual_time.minute.out + ":" + actual_time.second.out
		end

feature{NONE} -- Implementation		

	all_procedures: LINKED_LIST[PROCEDURE[ANY, TUPLE]]
			-- Container for all procedures except tours.	

	all_tours: LINKED_LIST[PROCEDURE[ANY, TUPLE]]
			-- Container for all tours.

	real_ms_start: INTEGER
			-- Value of `ticks' in EM_TIME when our time counting started

	simulated_ms_start: INTEGER
			-- Start counting with this value

	update_agent: PROCEDURE [ANY, TUPLE]
			-- Agent used for updating current simulated time

	update_time
			-- Update the time count
		require
			actual_time.second >= 0
			actual_time.minute >= 0
			actual_time.hour >= 0
		deferred
		end

feature -- Procedures

	add_callback_procedure (a_procedure: PROCEDURE[ANY, TUPLE])
			-- Add a procedure.
		require
			a_procedure_exists: a_procedure /= Void
		do
			all_procedures.force (a_procedure)
		end

	add_callback_tour (a_tour_procedure: PROCEDURE[ANY, TUPLE])
			-- Add the tour algorithms here.
		require
			a_procedure_exists: a_tour_procedure /= Void
		do
			all_tours.force (a_tour_procedure)
		end

	call_tours
			-- Call all procedures all 'an_interval' milliseconds.
		do
			from
				all_tours.start
			until
				all_tours.after
			loop
				all_tours.item.call ([Void])
				all_tours.forth
			end
		end

	call_procedure
			-- Call all procedures all 'an_interval' milliseconds.
		do
			from
				all_procedures.start
			until
				all_procedures.after
			loop
				all_procedures.item.call ([Void])
				all_procedures.forth
			end
		end

invariant

	actual_time.hour >= 0
	actual_time.minute >= 0

end
