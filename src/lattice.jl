struct RodLat2D
	grid::BitArray
	rods::Vector{Vector{NTuple{2, Int64}}} # [horizontals, verticals]
	L::Int64
	M::Int64
	z::Float64 # z = exp(βμ)
	RodLat2D(M::Int64, L::Int64, z::Float64) = new(falses(M, M), [NTuple{2, Int}[], NTuple{2, Int}[]], L, M, z)
end

function is_colliding(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)
	if horizontal
		return any(view(lat.grid, mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)))
	else
		return any(view(lat.grid, mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)))
	end
end

function insert_rod!(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool; test_collision=false)
	if horizontal
		if !test_collision || !is_colliding(lat, xy, true)
			lat.grid[mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)] .= 1
			append!(lat.rods[1], [xy])
		end
	else
		if !test_collision || !is_colliding(lat, xy, false)
			lat.grid[mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)] .= 1
			append!(lat.rods[2], [xy])
		end
	end
end

function delete_rod!(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)
	if horizontal
		if (all(view(lat.grid, mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M))))
			lat.grid[mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)] .= 0
			lat.rods[1] = filter(x -> x != xy, lat.rods[1])
			return true
		else
			return false
		end
	else
		if (all(view(lat.grid, mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M))))
			lat.grid[mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)] .= 0
			lat.rods[2] = filter(x -> x != xy, lat.rods[2])
		end
	end
end

function delete_rod!(lat::RodLat2D, xy::NTuple{2, Int})
	if findfirst(x -> x == xy, lat.rods[1]) != nothing
		delete_rod!(lat, xy, true)
	else
		delete_rod!(lat, xy, false)
	end
end