using Plots

function progress_bar(progress::Number; width=displaysize(stdout)[2], keep_bar=false)
	progress = float(progress)
	if progress < 0
		progress = 0.0
	elseif progress > 1
		progress = 1.0
	end
	
	if progress == 1
		if keep_bar
			println("\r" * "█"^round(Int, progress*width) * "━"^round(Int, (1-progress)*width))
		else
			print("\r" * " "^round(Int, progress*width) * "━"^round(Int, (1-progress)*width)*"\r")
		end
	else
		print("\r" * "█"^round(Int, progress*width) * "━"^round(Int, (1-progress)*width))
	end
end

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