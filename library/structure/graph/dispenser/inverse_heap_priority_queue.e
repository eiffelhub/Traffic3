note
	description: "[
		Heap priority queue sorted such that the item with the lowest
		priority is placed at the head of the queue.
		]"
	author: "Olivier Jeger"
	date: "$Date: 2010-06-28 20:14:26 +0200 (Пн, 28 июн 2010) $"
	revision: "$Revision: 1133 $"

class
	INVERSE_HEAP_PRIORITY_QUEUE [G -> COMPARABLE]

inherit
	HEAP_PRIORITY_QUEUE [G]
		redefine
			safe_less_than
		end

create
	make

feature {NONE} -- Comparison

	safe_less_than (a, b: G): BOOLEAN 
			-- Same as `a > b' when `a' and `b' are not Void.
			-- If `b' is Void and `a' is not, then True
			-- Otherwise False
		do
			if a /= Void and b /= Void then
				Result := a > b
			elseif a /= Void and b = Void then
				Result := True
			else
				Result := False
			end
		end

end
