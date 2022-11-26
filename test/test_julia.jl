using Test
using AllanDeviations
include("../julia/fun_avar.jl")
include("../julia/fun_tau_array.jl")

input = Float64[3;1;0;-4;5;2];
m = [1;2];
fs = 1.0;

# Homemade Allan variance function
(taus, avar) = fun_avar(input, fs, m)

# Allan deviation from library
(taus1,adev1) = allandev(input, fs, frequency=true, taus=length(m)) 
avar1 = adev1.^2

# Testing for homemade algorithm output
@testset "Allan variance" begin

    @test avar[1]-avar1[1] < 3
    @test avar[2]-avar1[2] < 0.1

    # test max m input
    # @test fun_avar([1;2;3;4], 1, [1;2])
    # test minimum input length
    # @test fun_avar([1;2], 1, [1])

end

# Testing correlation time function

@testset "Correlation array" begin

    # @test fun_tau_array(2,3) # max m length
    @test length(fun_tau_array(4,2)) == 2
    @test length(fun_tau_array(10,2)) == 2
    @test fun_tau_array(6,3)[end] == 2 # max multiple of 2
    @test fun_tau_array(8,3)[end] == 4 # max multiple of 2

end
