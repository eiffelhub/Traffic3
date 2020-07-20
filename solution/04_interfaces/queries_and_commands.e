class QUERIES_AND_COMMANDS inherit
	TOURISM

feature -- Commands and Queries

	tryout 
			-- Try out queries and commands on lines.
		do
			Paris.display
			Console.show (Line8.count)
			Console.show (Line8.i_th (1))
			Console.show (Line8.i_th (2))
			wait
			Line8.remove_all_segments
			Line8.extend (Station_La_Motte)
			Line8.extend (Station_Concorde)
			Line8.extend (Station_Invalides)
			Line8.highlight
			Console.show (Line8.count)
			Console.show (Line8.north_end.name)
		end

end
