using DelimitedFiles




include("src/lattice.jl")
include("src/solver.jl")
include("src/utils.jl")
include("test/tests.jl")
include("test/thermalisation_test.jl")
include("test/allg_test.jl")


therm_test()
# test()
# example_run()