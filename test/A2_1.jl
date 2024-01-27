function show_thermalisation(M, L, z, n; observables=Function[], observables_interval=max(1, n÷1e4))
	themalized = false
	therm_ind = 0
	therm_N = repeat([0], 75)
	observed_vals = [[] for i in eachindex(observables)]
	lat = RodLat2D(M, L, z)
	for i in 1:n
		# check for Thermalization
		if !themalized && i%length(therm_N) == 0
			if !any(iszero.(therm_N)) && maximum(therm_N) - minimum(therm_N) < lat.M^2 ÷ (L * 25)
				themalized = true
				therm_ind = i
			else
				therm_N[mod1((i÷length(therm_N)), length(therm_N)) |> Int] = length(lat.rods[1]) + length(lat.rods[2])
			end
		end

		# Progress bar
		if i % (n ÷ 1000) == 1 || i == n
			progress_bar(i/n, keep_bar=false)
		end

		# chose 50/50 if insertion or deletion
		if bitrand()[1] # insertion
			try_insert!(lat)
		else # deletion
			try_delete!(lat)
		end

		if i % observables_interval == 1
			for j in eachindex(observables)
				push!(observed_vals[j], observables[j](lat))
			end
		end 
	end
	return lat, observed_vals, therm_ind
end



function A2_1()
	n = 5e4
	M = 64
	L = 8
	z = 1.1
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	
	lat, obs, therm_ind= show_thermalisation(M, L, z, n, observables=[N, Nh, Nv], observables_interval=n÷100)
	plot(eachindex(obs[1]).* (n÷100) .- (1 - n÷100), obs[1:3], dpi=300, title="Thermalisation", label=["N" "Nh" "Nv"])
	vline!([therm_ind], label="Thermalization")
	savefig("media/A2_1/therm_test.png")
	visualize_RodLat2D(lat)
end