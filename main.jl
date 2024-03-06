script_start_time = time()


# when starting the script, the environment is activated and the necessary packages are loaded.
using  Pkg
Pkg.activate(@__DIR__)
using Statistics, Plots, Measurements, Random, BenchmarkTools, Interpolations, FourierTools, JLD2, CircularArrays

println("Packages loaded after ", time() - script_start_time, " seconds.")

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

# here you can create the act objects, if you want to use different values of z and/or steps.
# These parameters have to be adjustet in the functions.
# create_N_act_obj()
# create_S_act_obj()

# If test_mode = true, the tests will be executed with parameters that
# are not sufficient for a precise result, but demonstrate the functionality of the code.
# A2_1(test_mode=true)
# A2_2(test_mode=true)
# A2_3(test_mode=true)
# A2_4(test_mode=false)


println("Script execution time: ", time() - script_start_time)
nothing