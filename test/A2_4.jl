using Statistics
using Plots


function A2_4()
	zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
	M = 64
	L = 8
	n = 4e7
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2))
	absS(lat) = abs(S(lat))
	observables = [absS, η]
	obs_interv = n÷1e5

	obss = [[] for _ in zs]
	Threads.@threads for i in eachindex(zs)
		lat, obs, _ = simulate_RodLat2D(M, L, zs[i], n, observables=observables, observables_interval=obs_interv)
		obss[i] = obs
	end

	absSs = [mean(obs[1]) for obs in obss]
	ηs = [mean(obs[2]) for obs in obss]

	scatter(ηs, absSs, dpi=300, xlabel="η", ylabel="|S|", label="", title="M=$M, L=$L, steps=$n", legend=:topleft)

end