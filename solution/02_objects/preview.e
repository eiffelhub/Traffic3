class PREVIEW inherit
	TOURISM

feature -- Explore Paris

	explore 
			-- Show city info and a route.
		do
			Paris.display
			Louvre.spotlight
			Line8.highlight
			Route1.animate
			Console.show (Route1.origin)
		end

end
