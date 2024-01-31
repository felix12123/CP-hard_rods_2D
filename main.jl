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

A2_1()
A2_2()
A2_3()
A2_4()

nothing