using Statistics
using Plots
using Measurements

function A2_4(;test_mode=false)
	println("==================== A2_4 ====================")
	if test_mode
		M = 64
		L = 8
		n = 1e7
	else
		M = 64
		L = 8
		n = 4e8
	end
	zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
	
	# load act objects for observables
	absS_act = load_object("./src/act_objs/act_absS.jld2")
	η_act = load_object("./src/act_objs/act_η.jld2")
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2))
	absS(lat) = abs(S(lat))
	observables = [absS, η]

	# data storage
	obss = [[] for _ in zs]

	# simulate for different z
	Threads.@threads for i in eachindex(zs)
		_, obs, _ = simulate_RodLat2D(M, L, zs[i], n, observables=observables, observables_interval=[absS_act(zs[i]), η_act(zs[i])])
		obss[i] = obs
	end

	absSs = Measurement{Float64}[]
	ηs = Measurement{Float64}[]

	# create data for scatter plot with error bars
	for i in eachindex(obss)
		append!(absSs, mean(obss[i][1]) ± 1/sqrt(length(obss[i][1])) * std(obss[i][1]))
		append!(ηs,    mean(obss[i][2]) ± 1/sqrt(length(obss[i][1])) * std(obss[i][2]))
	end

	# create scatter plot
	plt = scatter(ηs, absSs, marker_z=zs, colorbar_title="z", dpi=300, xlabel="η", ylabel="|S|", label="", title="M=$M, L=$L, steps=$n", legend=:topleft)

	# save scatter plot
	savefig(plt, "media/A2_4/A2_4_scatter.png")
	return ηs, absSs
end