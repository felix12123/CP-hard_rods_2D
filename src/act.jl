using Interpolations
using FourierTools
using JLD2

# returns the autocorrelation time of the data
function act(data)
	if isempty(data)
		@warn "Empty data"
		return 0
	end
	data = data .- mean(data)
	a = FourierTools.ccorr(data, data)
	a = a ./ a[1]
	τ = findfirst(x -> x .< exp(-1), a)
	if τ === nothing
		display(plot(a))
		return 0
	end
	return τ
end

# returns a cubic interpolation of the data
function irreg_interp(xs::Vector{<:Real}, ys::Vector{<:Real})
	Interpolations.interpolate(xs, ys, FritschCarlsonMonotonicInterpolation())
end

# returns a cubic interpolation of the act function for each observable for variing z
function act_interp(M::Int, L::Int, ns::Vector{<:Real}, zs::Vector{<:Real}, obss; min_interv=2e2)
	# round n to integer
	ns = ceil.(Int, ns)
	zs = sort(zs) # needs to be sorted for interpolation

	if min_interv >= minimum(ns)
		@warn "min_interv is too small, or n is to large. setting it to 1"
		min_interv = 1
	end

	# calculate observables interval based on n to avoid memory issues and to speed up the simulation
	# larger values of n are typically chosen for larger z, so the observables interval is larger for larger z
	# because the observables are less likely to change.
	obs_intervals = [n > 1e4 ? min(10^8, max(min_interv, n÷1e5)) : 1 for n in ns]
	
	# simulate and collect observables.
	ds = [[] for _ in zs]
	Threads.@threads for i in eachindex(zs) |> reverse
		_, obs, _ = simulate_RodLat2D(M, L, zs[i], ns[i], observables=copy(obss), observables_interval=obs_intervals[i])
		ds[i] = obs
	end

	# check if shape of ds is correct
	@assert length(ds) == length(zs)
	@assert all(length(d_z) == length(obss) for d_z in ds)
	@assert all([!any(isempty.(d_z)) for d_z in ds])

	# calculate τs for each z and observable
	τss = [[act(obs_d) for obs_d in d_z] for d_z in ds]

	# transform dimensions of τss to be able to interpolate
	τss = hcat(τss...)
	τss = [τss[i,:] .* obs_intervals for i in axes(τss, 1)]

	# interpolate and return
	return [irreg_interp(zs, τs) for τs in τss]
end

# create act objects for the observables S, absS, Nh, and Nv
function create_S_act_obj()
	# observables
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	S(lat)  = (N1 = length(lat.rods[1]); N2 = length(lat.rods[2]); return (N1-N2)/(N1+N2))
	absS(lat) = abs(S(lat))
	
	# Adjust the parameters and observables here
	observables = [S, absS, Nh, Nv]
	zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
	ns = [4e9,  4e9,   4e9,  4e9,  4e9,  1e10, 1e10,  1e11]
	
	act_funcs = act_interp(64, 8, ns, zs, observables, min_interv=1e4)
	display(act_funcs)
	
	# save act objects to file, so they dont have to be recalculated every time
	for i in eachindex(observables)
		save_object("./src/act_objs/act_$(observables[i]).jld2", act_funcs[i])
	end
end

# create act objects for the observables N and η
function create_N_act_obj()
	# observables
	N(lat)  = sum(length.(lat.rods))
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	
	# Adjust the parameters and observables here. N and η have the same act, but are saved separately for consistency.
	observables = [N, η]
	zs = [0.05, 0.125, 0.25, 0.56, 0.84, 1.1, 1.15, 1.5]
	ns = [1e8,  1e8,   1e8,  1e8,  1e8,  2e8, 5e8,  1e9]
	
	act_funcs = act_interp(64, 8, ns, zs, observables)
	
	# save act objects to file, so they dont have to be recalculated every time
	for i in eachindex(observables)
		save_object("./src/act_objs/act_$(observables[i]).jld2", act_funcs[i])
	end
end

# display the act function of the act object at path
function display_actjdl(path::String)
	act_func = load_object(path)
	x = range(minimum(act_func.knots), maximum(act_func.knots), length=200)
	y = act_func.(x)
	plot(x, y) |> display
end
