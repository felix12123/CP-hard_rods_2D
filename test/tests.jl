function example_run()
	M = 64
	L = 8
	z = 1.1
	n = 4e7

	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2)) 

	observables = [N, Nh, Nv, S, η]
	obs_interv = n÷1e4
	lat, obs, _ = simulate_RodLat2D(M, L, z, n, observables=observables, observables_interval=obs_interv)

	rod_plt = visualize_RodLat2D(lat)
	N_plt = plot(eachindex(obs[1]).* obs_interv .- (1 - obs_interv), obs[1:3] .* [0.5, 1, 1], dpi=300, title="S", label=["N/2" "Nh" "Nv"])
	S_plt = plot(eachindex(obs[1]).* obs_interv .- (1 - obs_interv), obs[4], dpi=300, title="S", legend=false)
	hline!([0.0])
	η_plt = plot(eachindex(obs[5]).* obs_interv .- (1 - obs_interv), obs[5], dpi=300, title="η", legend=false, label=["η"])
	plot(N_plt, S_plt, η_plt, layout=(3,1))
end