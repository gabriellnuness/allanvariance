function fit_allanvar(taus::Array{Float64}, avar::Array{Float64})
# Calculate the sensor noise parameters/coefficients from the 
# Allan Variance data using Weighted Linear Regression
#
# ref: 2017_Jerath-Bridging the gap between sensor noise modeling and sensor characterization (https://doi.org/10.1016/j.measurement.2017.09.012 )
    
    ## Weighted Least-Squares Fitting
    
    # The weight is approximately to the order of magnitude
    weight = 1 ./avar
    W = diagm(weight)

    T = [taus.^(-2) taus.^(-1) taus.^(0) taus.^(1) taus.^(2)]

    avar_fit = (T'*W*T)\T'*W*avar

    ## Fitted Allan deviation noise values
    # This values result in complex numbers
    # C = avar_fit
    # unit = measurement unit in SI
    #
    # Q     --> unit * s
    # arw   --> unit * s^(1/2)
    # bias  --> unit * s^(0)
    # rrw   --> unit * s^(-1/2) 
    # rr    --> unit * s^(-1)
    #

    # C = 3*Q^2
    # Q^2 = (q^2)/12, where q = quantum step size
    Q    = (avar_fit[1]/3)^(0.5)
    # C = N^2
    arw  = avar_fit[2]^(0.5)
    # C = (0.6643*B)^2
    bias = (avar_fit[3]^(0.5)) / sqrt(2*log(2)/pi)
    # C = K^2 /3
    rrw  = (3*avar_fit[4])^(0.5)
    # C = R^2 / 2
    rr   = (2*avar_fit[5])^(0.5)

    adev_fit = sqrt.(avar_fit'*T')
    adev_fit = adev_fit[1,:]

    (adev_fit, Q, arw, bias, rrw, rr)
end