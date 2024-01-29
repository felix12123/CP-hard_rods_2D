using Plots

"""
	progress_bar(progress::Number; width=displaysize(stdout)[2], keep_bar=false)

Prints a progress bar to the console based on the given progress value.

Arguments:
- `progress::Number`: The progress value between 0 and 1.
- `width::Int`: The width of the progress bar (default is the width of the console).
- `keep_bar::Bool`: Whether to keep the progress bar after it reaches 100% (default is `false`).

"""
function progress_bar(progress::Number; width=displaysize(stdout)[2], keep_bar=false)
	progress = float(progress)
	if progress < 0
		progress = 0.0
	elseif progress > 1
		progress = 1.0
	end
	
	if progress == 1
		if keep_bar
			print("\r" * "█"^round(Int, progress*width) * "━"^round(Int, (1-progress)*width))
		else
			print("\r" * " "^width*"\r")
		end
	else
		print("\r" * "█"^round(Int, progress*width) * "━"^round(Int, (1-progress)*width))
	end
end

function visualize_RodLat2D(lat)
	plt = plot(title="L = $(lat.L), M = $(lat.M), z = $(lat.z)", dpi=300, size=(400, 400), xlims=(-0.5, lat.M+0.5), ylims=(-0.5, lat.M+0.5))
	for xy in lat.rods[1]
		ys = repeat([xy[1]], lat.L)
		xs = mod1.(xy[2]:xy[2]+lat.L-1, lat.M)
		scatter!(plt, xs, ys, color=:red, markersize=64^2 / 24 / lat.M, label="", markershape=:rect)
	end
	for xy in lat.rods[2]
		xs = repeat([xy[2]], lat.L)
		ys = mod1.(xy[1]:xy[1]+lat.L-1, lat.M)
		scatter!(plt, xs, ys, color=:blue, markersize=64^2 / 24 / lat.M, label="", markershape=:rect)
	end
	return plt
end