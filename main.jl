script_start_time = time()


# using  Pkg
# cd(Base.source_dir())
# Pkg.activate(".")

using Statistics, Plots, Measurements, Random, BenchmarkTools, Interpolations, FourierTools, JLD2, CircularArrays

dirs = ["media", "media/A2_1", "media/A2_2", "media/A2_3", "media/A2_4", "src/act_objs"]
for dir in dirs
	if !isdir(dir)
		mkdir(dir)
	end
end

include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")
include("src/act.jl")

include("test/A2_1.jl") # Thermalization
include("test/A2_2.jl") # comparison of 3 zs and few/many steps
include("test/A2_3.jl") # 
include("test/A2_4.jl")


# create_N_act_obj()
# create_S_act_obj()

A2_1(test_mode=true)
A2_2(test_mode=true)
A2_3(test_mode=true)
A2_4(test_mode=true)

println("Script execution time: ", time() - script_start_time)
nothing