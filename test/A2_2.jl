function A2_2()
	M = 64
	L = 8
	zs = [0.56, 0.84, 1.1]
	n = 4e5

	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2)) 

	observables = [N, Nh, Nv, S, η]
	obs_interv = n÷1e5
	
	@time Threads.@threads for i in eachindex(zs)
		lat, obs, _ = simulate_RodLat2D(M, L, zs[i], n, observables=observables, observables_interval=obs_interv)

		# histogram for many steps
		hist = histogram(obs[2], dpi=300, label="Nh", title="M=$M, L=$L, z=$(zs[i]), steps=$n", legend=:topleft, alpha=0.5)
		histogram!(obs[3], label="Nv", alpha=0.5)
		histogram!(obs[1] ./ 2, label="N/2", alpha=0.5)
		savefig(hist, "media/A2_2/A2_2_hist_many_steps_z$(zs[i]).png")
		
		# histogram for too few steps
		n_few = length(obs[1])÷100
		hist = histogram(obs[2][1:n_few], dpi=300, label="Nh", title="M=$M, L=$L, z=$(zs[i]), steps=$(n/100)", legend=:topleft, alpha=0.5)
		histogram!(obs[3][1:n_few], label="Nv", alpha=0.5)
		histogram!(obs[1][1:n_few] ./ 2, label="N/2", alpha=0.5)
		savefig(hist, "media/A2_2/A2_2_hist_few_steps_z$(zs[i]).png")
	end


end