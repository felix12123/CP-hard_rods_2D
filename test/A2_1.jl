function show_thermalisation(M, L, z, n; observables=Function[], observables_interval=max(1, n÷1e4))
	n = ceil(Int, n)

	pre_therm_pic = false
	themalized = false
	therm_ind = n
	observed_vals = [[] for i in eachindex(observables)]
	lat = RodLat2D(M, L, z)

	Ns = zeros(Int, n)
	N(lat) = length(lat.rods[1]) + length(lat.rods[2])
	
	for i in 1:n
		# check for Thermalization
		Ns[i] = N(lat)
		if !themalized && i > M^2/2
			if (Ns[i] - Ns[max(1, i-M^2)]) < (-0.01 * Ns[i])
				# println(Ns[i], "   ",  Ns[max(1, i-M^2)], "   ",  Ns[i] - Ns[max(1, i-M^2)])
				savefig(visualize_RodLat2D(lat), "media/A2_1/therm_lat.png")
				themalized = true
				therm_ind = i - M^2/2
			else
				if !pre_therm_pic && i > 1e4
					pre_therm_pic = true
					savefig(visualize_RodLat2D(lat), "media/A2_1/pre_therm_lat.png")
				end
			end
		end

		# chose 50/50 if insertion or deletion
		if rand((true, false)) # insertion
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
	println("==================== A2_1 ====================")
	n = 5e4
	M = 64
	L = 8
	z = 0.84
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	
	obs_int = n ÷ 2000
	lat, obs, therm_ind= show_thermalisation(M, L, z, n, observables=[N, Nh, Nv], observables_interval=obs_int)
	plot(eachindex(obs[1]).* (obs_int) .- (1 - obs_int), obs[1:3], dpi=300, title="Thermalisation", label=["N" "Nh" "Nv"])
	vline!([therm_ind], label="Thermalization")
	savefig("media/A2_1/therm_test.png")
end