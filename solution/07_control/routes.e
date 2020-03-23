note
	description: "Routes class (Chapter 7, Touch of Class)"
	date: "$Date$"
	revision: "$Revision$"

class
	ROUTES

inherit

	TOURISM

feature -- Routes

	traverse 
			-- Build a route and traverse Line8.
		do
			Paris.display

			-- Path
			create walking_1.make_walk (Elysee_palace, Station_Charles_de_Gaulle_Etoile)
			create metro_1.make_metro (Station_Charles_de_Gaulle_Etoile, Station_Champs_de_Mars_Tour_Eiffel_Bir_Hakeim)
			create walking_2.make_walk (Station_Champs_de_Mars_Tour_Eiffel_Bir_Hakeim, Eiffel_Tower)
			create full.make_empty
			full.extend (walking_1)
			full.extend (metro_1)
			full.extend (walking_2)
			Paris.routes.put_last (full)
			full.illuminate

			-- Loop
			from
				Line8.start
			invariant
				not_before_unless_empty: (not Line8.is_empty) implies (not Line8.is_before)
				-- "For all stations before cursor position, a spot has been displayed"
			variant
				Line8.count - Line8.index + 1
			until
				Line8.after
			loop
				if Line8.item.is_railway_connection then
					show_big_red_spot (Line8.item.location)
				elseif Line8.item.is_exchange then
					show_blinking_spot (Line8.item.location)
				else
					show_spot (Line8.item.location)
				end
				Line8.forth
			end
		end


	full: TRAFFIC_ROUTE
	walking_1, walking_2, metro_1: TRAFFIC_LEG

end
