using Random




function try_insert!(lat::RodLat2D)
	N = length(lat.rods[1]) + length(lat.rods[2])
	α_ins = 2*lat.M^2 / (N+1) * z
	xy = (rand(1:lat.M), rand(1:lat.M-lat.L+1))

	if bitrand()[1] # horizontal
		if rand() < α_ins && !is_colliding(lat, xy, true)
			insert_rod!(lat, xy, true, test_collision=false)
			return true
		else
			return false
		end
	else # vertical
		if rand() < α_ins && !is_colliding(lat, xy, false)
			insert_rod!(lat, xy, false, test_collision=false)
			return true
		else
			return false
		end
	end
end

function try_delete!(lat::RodLat2D)
	N = length(lat.rods[1]) + length(lat.rods[2])
	α_del = N / (2 * lat.M^2 * z)
	if rand() < α_del
		i = rand(1:N)
		if i <= length(lat.rods[1])
			delete_rod!(lat, lat.rods[1][i], true)
		else
			delete_rod!(lat, lat.rods[2][i-length(lat.rods[1])], false)
		end
		return true
	else
		return false
	end
end


function simulate_RodLat2D(M, L, z, n; observables=Function[], observables_interval=1e2)
	observed_vals = [[] for i in eachindex(observables)]
	lat = RodLat2D(M, L, z)
	for i in 1:n
		if bitrand()[1] # insertion
			try_insert!(lat)
		else # deletion
			try_delete!(lat)
		end
	
		if i % observables_interval == 1
			for j in eachindex(observables)
				push!(observed_vals[j], observables[j](lat))
			end
		end 
	end
	return lat, observed_vals
end

