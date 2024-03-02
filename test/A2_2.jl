function A2_2(;test_mode=false)
	println("==================== A2_2 ====================")
	M = 64
	L = 8
	zs = [0.56, 0.84, 1.1]
	n = 4e9
	# n = 4e8

	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)

	observables = [N, Nh, Nv]
	# obs_interv = 2e4
	obss = [[] for i in eachindex(zs)]
	Threads.@threads for i in eachindex(zs)
		obss[i] = simulate_RodLat2D(M, L, zs[i], n, observables=observables)[2]
	end
	for i in eachindex(zs)
		# histogram for many steps
		hist = histogram(obss[i][2], dpi=300, label="Nh", title="M=$M, L=$L, z=$(zs[i]), steps=$n", legend=:topleft, alpha=0.5, bins=100)
		histogram!(obss[i][3], label="Nv", alpha=0.5, bins=100)
		histogram!(twinx(), obss[i][1] ./ 2, label="N/2", alpha=0.5, bins=15, legend=:topright, color=:green)
		savefig(hist, "media/A2_2/A2_2_hist_many_steps_z$(zs[i]).png")
		
		# histogram for too few steps
		n_few = length(obss[i][1])÷100
		hist = histogram(obss[i][2][1:n_few], dpi=300, label="Nh", title="M=$M, L=$L, z=$(zs[i]), steps=$(n/100)", legend=:topleft, alpha=0.5, bins=100÷2)
		histogram!(obss[i][3][1:n_few], label="Nv", alpha=0.5, bins=100÷2)
		histogram!(twinx(), obss[i][1][1:n_few] ./ 2, label="N/2", alpha=0.5, bins=15÷2, legend=:topright, color=:green)
		savefig(hist, "media/A2_2/A2_2_hist_few_steps_z$(zs[i]).png")
	end
end