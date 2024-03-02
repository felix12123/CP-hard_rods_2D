using Statistics
using Plots
using Measurements

function A2_4(;test_mode=false)
	println("==================== A2_4 ====================")
	if test_mode
		zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
		M = 64
		L = 8
		n = 4e7
	else
		zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
		M = 64
		L = 8
		n = 4e9
	end

	absS_act = load_object("./src/act_objs/act_absS.jld2")
	η_act = load_object("./src/act_objs/act_η.jld2")
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2))
	absS(lat) = abs(S(lat))
	observables = [absS, η]
	# obs_interv = min(2e4, n÷1e5)

	# obs_int = 1e2
	obss = [[] for _ in zs]
	Threads.@threads for i in eachindex(zs)
		lat, obs, _ = simulate_RodLat2D(M, L, zs[i], n, observables=observables, observables_interval=[absS_act(zs[i]), η_act(zs[i])])
		obss[i] = obs
	end

	absSs = Measurement{Float64}[]
	ηs = Measurement{Float64}[]

	for i in eachindex(obss)
		append!(absSs, mean(obss[i][1]) ± 1/sqrt(length(obss[i][1])) * std(obss[i][1]))
		append!(ηs,    mean(obss[i][2]) ± 1/sqrt(length(obss[i][1])) * std(obss[i][2]))
	end

	plt = scatter(ηs, absSs, marker_z=zs, colorbar_title="z", dpi=300, xlabel="η", ylabel="|S|", label="", title="M=$M, L=$L, steps=$n", legend=:topleft)
	savefig(plt, "media/A2_4/A2_4_scatter.png")
	return ηs, absSs
end