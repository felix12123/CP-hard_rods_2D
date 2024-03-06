"""
	struct RodLat2D

A struct representing a 2D lattice of rods.

# Fields
- `grid::BitArray`: A 2D grid representing the lattice.
- `rods::Vector{Vector{NTuple{2, Int64}}}`: A vector of vectors representing the positions of horizontal and vertical rods.
- `L::Int64`: The length of the rods.
- `M::Int64`: The width of the lattice.
- `z::Float64`: The parameter z = exp(βμ).

# Constructors
- `RodLat2D(M::Int64, L::Int64, z::Float64)`: Constructs a new `RodLat2D` object with the given parameters.

"""
struct RodLat2D
	grid::BitArray
	rods::Vector{Vector{NTuple{2, Int64}}}
	L::Int64
	M::Int64
	z::Float64
	RodLat2D(M::Int64, L::Int64, z::Float64) = new(falses(M, M), [NTuple{2, Int}[], NTuple{2, Int}[]], L, M, z)
end

"""
	is_colliding(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)

Check if there is a collision between rods in the lattice.

Arguments
- `lat::RodLat2D`: The 2D lattice of rods.
- `xy::NTuple{2, Int}`: The coordinates of the rod to check for collision.
- `horizontal::Bool`: Flag indicating whether the rod is horizontal or vertical.

Returns
- `Bool`: `true` if there is a collision, `false` otherwise.
"""
function is_colliding(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)
	if horizontal
		for i in xy[2]:xy[2]+lat.L-1
			if lat.grid[mod1(xy[1], lat.M), mod1(i, lat.M)]
				return true
			end
		end
	else
		for i in xy[1]:xy[1]+lat.L-1
			if lat.grid[mod1(i, lat.M), mod1(xy[2], lat.M)]
				return true
			end
		end
	end
	return false
end
function is_colliding_old(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)
	if horizontal
		return any(view(lat.grid, mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)))
	else
		return any(view(lat.grid, mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)))
	end
end


"""
	insert_rod!(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool; test_collision=true)

Inserts a rod into the lattice at the specified coordinates.

Arguments:
- `lat::RodLat2D`: The 2D lattice to insert the rod into.
- `xy::NTuple{2, Int}`: The coordinates of the rod's starting position.
- `horizontal::Bool`: Specifies whether the rod should be inserted horizontally or vertically.
- `test_collision::Bool=false`: If `true`, checks for collisions before inserting the rod.

"""
function insert_rod!(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool; test_collision=true)
	if horizontal
		if !test_collision || !is_colliding(lat, xy, true)
			lat.grid[mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)] .= 1
			append!(lat.rods[1], [xy])
			return true
		end
	else
		if !test_collision || !is_colliding(lat, xy, false)
			lat.grid[mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)] .= 1
			append!(lat.rods[2], [xy])
			return true
		end
	end
	return false
end
# insert_rod!(;lat=RodLat2D(16, 4, 0.5), pos=(10, 15), horizontal=rand((true, false)))=insert_rod!(lat, pos, horizontal)

"""
	delete_rod!(lat::RodLat2D, xy::NTuple{2, Int}, horizontal::Bool)

Delete a rod from the lattice grid.

Arguments:
- `lat::RodLat2D`: The 2D lattice object.
- `xy::NTuple{2, Int}`: The coordinates of the rod to be deleted.
- `horizontal::Bool`: A flag indicating whether the rod is horizontal (true) or vertical (false).

Returns:
- `true` if the rod was successfully deleted.
- `false` if the rod could not be deleted due to overlapping with other rods.

"""
function delete_rod!(lat::RodLat2D, i::Int, horizontal::Bool)
	if horizontal
		xy = lat.rods[1][i]
		lat.grid[mod1(xy[1], lat.M), mod1.(xy[2]:xy[2]+lat.L-1, lat.M)] .= 0
		deleteat!(lat.rods[1], i)
	else
		xy = lat.rods[2][i]
		lat.grid[mod1.(xy[1]:xy[1]+lat.L-1, lat.M), mod1(xy[2], lat.M)] .= 0
		deleteat!(lat.rods[2], i)
	end
end
