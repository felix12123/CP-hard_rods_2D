using DelimitedFiles
using Plots
using Random


dirs = ["media", "media/A2_1", "media/A2_2", "media/A2_3", "media/A2_4"]

if !isdir(dirs[1])
	mkdir(dirs[1])
end

include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")
include("test/A2_2.jl")
include("test/thermalisation_test.jl")
include("test/allg_test.jl")
include("test/A2_3.jl")
include("test/A2_4.jl")

# A2_1()
# A2_2()
# A2_3()
# A2_4()