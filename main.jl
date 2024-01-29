using Pkg
# Check if packages are installed, else install them
Packages = ["Statistics", "Plots", "Measurements", "LsqFit", "Random", "DelimitedFiles"]
for Package in Packages
  try
    eval(Meta.parse("using $Package"))
  catch
    println("Package $Package was not found. Installation started")
    Pkg.add(Package)
    eval(Meta.parse("using $Package"))
  end
end


dirs = ["media", "media/A2_1", "media/A2_2", "media/A2_3", "media/A2_4"]
for dir in dirs
	if !isdir(dir)
		mkdir(dir)
	end
end

include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")

include("test/A2_1.jl") # Thermalization
include("test/A2_2.jl") # comparison of 3 zs and few/many steps
include("test/A2_3.jl")
include("test/A2_4.jl")

# A2_1()
# A2_2()
# A2_3()
# A2_4()

function start()
  N=1
  Ss = [[] for i in 1:N]
  S1 = (lat) -> (N1 = length(lat.rods[1]); N2 = length(lat.rods[2]); return (N1-N2)/(N1+N2))
  for i in 1:N
    Ss[i] = simulate_RodLat2D(64, 8, 0.84, 1e8, observables=[S1], observables_interval=2e4)[2][1]
  end
  Ss = vcat(Ss...)
  # histogram(Ss, dpi=300, title="S for M=64, L=8, steps=1e6", legend=:topleft, bins=100) |> display
end

@time start()
# 123M
# 
nothing
# display(make_thermalized_lat(64, 8, 0.5, 1e6)[1])