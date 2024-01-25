using Plots

function visualize_RodLat2D(lat)
	plt = plot(title="L = $(lat.L), M = $(lat.M), z = $(lat.z)", dpi=300)
	for xy in lat.rods[1]
		ys = repeat([xy[1]], lat.L)
		xs = xy[2]:xy[2]+lat.L-1
		plot!(plt, xs, ys, color=:red, lw=0.5, label="")
	end
	for xy in lat.rods[2]
		xs = repeat([xy[2]], lat.L)
		ys = xy[1]:xy[1]+lat.L-1
		plot!(plt, xs, ys, color=:blue, lw=0.5, label="")
	end
	return plt
end