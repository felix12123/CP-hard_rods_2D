function test()
	
	n = 4e7
	M = 64
	L = 8
	zs = [0.56, 0.84, 1.1]
	z = zs[3]
	
	
	Nh(lat) = length(lat.rods[1])
	Nv(lat) = length(lat.rods[2])
	N(lat)  = Nh(lat) + Nv(lat)
	η(lat)  = lat.L * N(lat) / (lat.M^2)
	S(lat)  = (N1 = Nh(lat); N2 = Nv(lat); return (N1-N2)/(N1+N2)) 
	@time lat, observs, _ = simulate_RodLat2D(M, L, z, n, observables=[S], observables_interval=n÷1e4)
	
	
	
	open("n$(n)_M$(M)_L$(L)_z$z.csv", "w") do io
		writedlm(io, [(eachindex(observs[1]).* (n÷1e5)) observs[1]])
	end
	
	
	plt = visualize_RodLat2D(lat)
	display(plt)
	plt2 = histogram(observs[1], dpi=300, title="S", legend=false, xlims=(-1,1), bins=100)
	vline!([0.0])
	display(plt2)

end