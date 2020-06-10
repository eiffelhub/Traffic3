note
	description: "Factory for traffic type."
	date: "$Date: 2009-08-21 13:35:22 +0200 (Пт, 21 авг 2009) $"
	revision: "$Revision: 1098 $"

class
	TRAFFIC_TYPE_FACTORY

create
	make

feature {NONE} -- Initialization

	make
			-- Set internal traffic type representation to void.
		do
			internal_traffic_type := Void
		ensure
			internal_traffic_type_is_void: internal_traffic_type = Void
			type_table_exists: type_table /= Void
		end

feature -- Access

	traffic_type: TRAFFIC_TYPE
			-- Traffic type last created by `build'
		do
			Result := internal_traffic_type
		end

feature -- Basic operation

	reset 
			-- Reset internal traffic type representation.
		do
			internal_traffic_type := Void
		ensure
			internal_traffic_type_is_void: internal_traffic_type = Void
		end

	build (a_name: STRING)
			-- Build traffic type depending on type name `a_name'.
			-- Access traffic type with `traffic_type'.
		require
			a_name_valid: valid_name (a_name)
			a_name_not_empty: not a_name.is_empty
		do
			internal_traffic_type ?= type_table.item (a_name)
		ensure
			type_created: internal_traffic_type/=Void
			type_exists: has_type
		end

feature -- Status report

	valid_name (a_name: STRING): BOOLEAN
			-- Is `a_name' a valid traffic type name?
		require
			a_name_exists: a_name /= Void
			a_name_not_empty: not a_name.is_empty
		do
			Result := type_table.has (a_name)
		end

	has_type: BOOLEAN
			-- Has a type object been generated?
		do
			Result := internal_traffic_type /= Void
		end

feature {NONE} -- Implementation

	internal_traffic_type: TRAFFIC_TYPE
			-- Traffic type last created

	bus_type: TRAFFIC_TYPE_BUS
			-- Bus traffic type
		once
			create Result.make
		end

	rail_type: TRAFFIC_TYPE_RAIL
			-- Rail traffic type
		once
			create Result.make
		end

	tram_type: TRAFFIC_TYPE_TRAM
			-- Tram traffic type
		once
			create Result.make
		end

	walking_type: TRAFFIC_TYPE_WALKING
			-- Walking traffic type
		once
			create Result.make
		end

	street_type: TRAFFIC_TYPE_STREET
			-- Street type
		once
			create Result.make
		end

	lightrail_type: TRAFFIC_TYPE_LIGHTRAIL
			-- Lightrail type
		once
			create Result.make
		end

	railroad_type: TRAFFIC_TYPE_RAILROAD
			-- Railroad type
		once
			create Result.make
		end

	type_table: HASH_TABLE [TRAFFIC_TYPE, STRING]
			-- Table with all types
		once
			create Result.make (9)
			-- TRAFFIC_LINE_TYPEs
			Result.extend (bus_type, bus_type.name)
			Result.extend (rail_type, rail_type.name)
			Result.extend (tram_type, tram_type.name)
			-- TRAFFIC_ROAD_TYPEs
			Result.extend (lightrail_type, lightrail_type.name)
			Result.extend (railroad_type, railroad_type.name)
			Result.extend (street_type, street_type.name)
			Result.extend (walking_type, walking_type.name)
			Result.compare_objects
		end

end
