struct RodLat2D
	grid::BitArray
	rods::Vector{Vector{NTuple{2, Int64}}} # [horizontals, verticals]
	L::Int64
	M::Int64
	z::Float64 # z = exp(βμ)
	RodLat2D(M::Int64, L::Int64, z::Float64) = new(falses(M, M), [NTuple{2, Int}[], NTuple{2, Int}[]], L, M, z)
end