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
	
	if rand() < α_ins
		xy = (rand(1:lat.M), rand(1:lat.M-lat.L+1))
		return insert_rod!(lat, xy, rand((0,1)))
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
	α_del = N / (2 * lat.M^2 * lat.z)
	if rand() < α_del
		i = rand(1:N)
		if i <= length(lat.rods[1])
			delete_rod!(lat, lat.rods[1][i], true)
		else
			delete_rod!(lat, lat.rods[2][i-length(lat.rods[1])], false)
		end
		return true
	end
	return false
end



function make_thermalized_lat(M, L, z, n)
	themalized = false
	therm_N = repeat([0], 75)
	lat = RodLat2D(M, L, z)
	
	for i in 1:n
		# check for Thermalization
		if !themalized && i%length(therm_N) == 0
			if !any(iszero.(therm_N)) && maximum(therm_N) - minimum(therm_N) < lat.M^2 ÷ (L * 25)
				themalized = true
				return lat, i
			else
				therm_N[mod1((i÷length(therm_N)), length(therm_N)) |> Int] = length(lat.rods[1]) + length(lat.rods[2])
			end
		end

		# chose 50/50 if insertion or deletion
		if rand((0,1)) # insertion
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
function simulate_RodLat2D(M::Real, L::Real, z::Real, n::Real; observables=Function[], observables_interval=max(1, n÷1e4))
		n = ceil(Int, n)
		M = ceil(Int, M)
		L = ceil(Int, L)
		
	# storage containers for observables
	observed_vals = [[] for i in eachindex(observables)]

	# prethermalize the lattice
	lat, therm_ind = make_thermalized_lat(M, L, z, n)

	# run simulation
	for i in 1:n
		# Progress bar
		if i % (n ÷ 100) == 1
			progress_bar(i/n, keep_bar=false)
		end

		# chose 50/50 if insertion or deletion
		if rand((0,1)) # insertion
			try_insert!(lat)
		else # deletion
			try_delete!(lat)
		end

		# calculate observables
		if i % observables_interval == 1
			for j in eachindex(observables)
				push!(observed_vals[j], observables[j](lat))
			end
		end 
	end

	progress_bar(1.0, keep_bar=false)
	return lat, observed_vals, therm_ind
end



