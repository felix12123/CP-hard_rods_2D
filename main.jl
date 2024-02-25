script_start_time = time()

using Statistics, Plots, Measurements, Random, DelimitedFiles, BenchmarkTools, Interpolations, FourierTools, JLD2, CircularArrays, HTTP

dirs = ["media", "media/A2_1", "media/A2_2", "media/A2_3", "media/A2_4", "src/act_objs"]
for dir in dirs
	if !isdir(dir)
		mkdir(dir)
	end
end

include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")
# include("src/auto_corr.jl")

include("test/A2_1.jl") # Thermalization
include("test/A2_2.jl") # comparison of 3 zs and few/many steps
include("test/A2_3.jl") # 
include("test/A2_4.jl")

include("src/act.jl")


if time() - script_start_time > 60 * 5
	HTTP.request("POST", "https://ntfy.sh/julia_scripts46182355781653856", body="Ising hat fertig kompiliert. Es lief $((time() - script_start_time)÷60) Minuten")
end

# A2_1()
# A2_2()
# A2_3()
# A2_4()

nothing

# optimization improvements:
# 166 ms # before optimization
# 116 ms # is colliding update
# 91  ms # insertion/deletion optimization
# @benchmark simulate_RodLat2D(64, 8, 0.84, 1e6) seconds=10