function A2_3(;test_mode=false)
	println("==================== A2_3 ====================")

	# set parameters for test or full run
	if test_mode
		n = 4e8
		M = 64 ÷ 2
		L = 8 ÷ 2
		zs = Float64[0.56, 0.84, 1.1]
	else
		n = 4e9
		M = 64
		L = 8
		zs = Float64[0.56, 0.84, 1.1]
	end

	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2))

	observables = [S]
	# obs_interv = 2e4
	hist = histogram(dpi=300, title="S for M=$M, L=$L, steps=$n", legend=:topleft)
	res = [[], [], []]
	obs_interv = n ÷ 4e6
	Threads.@threads for i in eachindex(zs)
		lat, obs, _ = simulate_RodLat2D(M, L, zs[i], n, observables=observables, observables_interval=obs_interv)
		res[i] = obs[1]
	end
	for i in eachindex(zs)
		histogram!(hist, res[i], label="z=$(zs[i])", alpha=0.5, bins=100)
	end
	savefig(hist, "media/A2_3/A2_3_hist.png")
	return res
end