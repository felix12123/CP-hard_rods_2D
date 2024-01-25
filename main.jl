



# steps for simulaiton: 4e9
# Histogram for horizontal or vertical rods


include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")
n = 4e8
M = 64
L = 8
zs = [0.56, 0.84, 1.1]
z = zs[1]


Nh(lat) = length(lat.rods[1]) / (length(lat.rods[1]) + length(lat.rods[2]))
@time lat, observs = simulate_RodLat2D(M, L, z, n, observables=[Nh], observables_interval=n÷1e5)


plt = visualize_RodLat2D(lat)
display(plt)
display(histogram(observs[1], dpi=300, title="N_h", legend=false))


