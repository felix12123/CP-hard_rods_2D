using Random



"""
	try_insert!(lat::RodLat2D)

Attempt to insert a rod into the lattice `lat` according to the hard rod model in 2D.

# Arguments
- `lat::RodLat2D`: The lattice object representing the 2D system of rods.

# Returns
- `Bool`: `true` if the insertion was successful, `false` otherwise.
"""
function try_insert!(lat::RodLat2D)::Bool
	N = length(lat.rods[1]) + length(lat.rods[2])
	α_ins = 2*lat.M^2 / (N+1) * lat.z
	if α_ins > 1 || rand() < α_ins
		xy = (rand(1:lat.M), rand(1:lat.M))
		return insert_rod!(lat, xy, rand((true, false)))
	end
	return false
end


"""
	try_delete!(lat::RodLat2D)

Attempt to delete a rod from the lattice `lat` based on a deletion probability `α_del`.
If a rod is successfully deleted, the function returns `true`, otherwise it returns `false`.

# Arguments
- `lat::RodLat2D`: The 2D rod lattice.

# Returns
- `Bool`: `true` if a rod is deleted, `false` otherwise.
"""
function try_delete!(lat::RodLat2D)
	N = length(lat.rods[1]) + length(lat.rods[2])
	if rand() < N / (2 * lat.M^2 * lat.z)
		i = ceil(Int, rand()*N)
		if i <= length(lat.rods[1])
			# delete_rod!(lat, lat.rods[1][i], true)
			delete_rod!(lat, i, true)
		else
			delete_rod!(lat, i-length(lat.rods[1]), false)
		end
		return true
	end
	return false
end

function get_thermalisation_time(M, L, z, n_max, trys=10)::Int
	s = 0.0
	for _ in 1:trys
		s += make_thermalized_lat(M, L, z, n_max)[2]
	end
	return s ÷ trys
end



function make_thermalized_lat(M, L, z, n)
	n = ceil(Int, n)

	N(lat) = length(lat.rods[1]) + length(lat.rods[2])
	Ns = zeros(Int, n)
	lat = RodLat2D(M, L, z)
	
	for i in 1:n
		Ns[i] = N(lat)
		if (Ns[i] - Ns[max(1, i-M^2)]) < (-0.01 * Ns[i])
			return lat, i-M^2/2
		end

		# chose 50/50 if insertion or deletion
		if rand((true, false)) # insertion
			try_insert!(lat)
		else # deletion
			try_delete!(lat)
		end 
	end
	error("Thermalization not reached after $n steps.")
end


"""
simulate_RodLat2D(M, L, z, n; observables=Function[], observables_interval=1e2)

Simulates the behavior of a 2D lattice of rods.

# Arguments
- `M`: Number of rows in the lattice.
- `L`: Number of columns in the lattice.
- `z`: Number of rods to insert initially.
- `n`: Number of simulation steps.

# Keyword Arguments
- `observables`: Array of functions that calculate observables of the lattice.
- `observables_interval`: Interval at which observables are calculated.

# Returns
- `lat`: The final state of the lattice.
- `observed_vals`: Array of observed values at each observables_interval.
"""
function simulate_RodLat2D(M::Real, L::Real, z::Real, n::Real; observables::Vector=Function[], observables_interval=0)
	observables_interval = ceil(Int, observables_interval)
	if observables_interval == 0
		observables_interval = get_thermalisation_time(M, L, z, n)
	end

	n = ceil(Int, n)
	M = ceil(Int, M)
	L = ceil(Int, L)
	println("starting eval with M=$M, L=$L, z=$z, n=$n, observables_interval=$observables_interval, observables=$(string.(observables))")
		
	# storage containers for observables
	observed_vals = [fill(NaN, ceil(Int, n / observables_interval)) for i in eachindex(observables)]

	# prethermalize the lattice
	lat, therm_ind = make_thermalized_lat(M, L, z, n)

	# run simulation
	for i in 1:n
		# Progress bar
		if i % (n ÷ 50) == 1
			progress_bar(i/n, keep_bar=false)
		end

		# chose 50/50 if insertion or deletion
		if rand((true, false)) # insertion
			try_insert!(lat)
		else # deletion
			try_delete!(lat)
		end

		# calculate observables
		if (i-1) % observables_interval == 0
			for j in eachindex(observables)
				observed_vals[j][ceil(Int, i/observables_interval)] = observables[j](lat)
			end
		end 
	end
	progress_bar(1.0, keep_bar=false)
	return lat, observed_vals, therm_ind
end



