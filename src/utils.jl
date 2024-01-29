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

import Base: display
function display(lat::RodLat2D)
	plt = plot(title="L = $(lat.L), M = $(lat.M), z = $(lat.z)", dpi=300, size=(400, 400), xlims=(-0.5, lat.M+0.5), ylims=(-0.5, lat.M+0.5))
	for xy in lat.rods[1]
		ys = repeat([xy[1]], lat.L)
		xs = mod1.(xy[2]:xy[2]+lat.L-1, lat.M)
		continuous(v) = (dv = v[2:end] .- v[1:end-1];return all(dv[1] .== dv) && (abs(dv[1]) == 1))
		if continuous(xs)
			plot!(plt, xs, ys, color=:red, linewidth=64^2 / 24 / lat.M * 1.5, label="")
		else
			len = 1 + lat.M - xs[1]
			xs1 = vcat(xs[1:len], xs[len] + 0.5)
			ys1 = ys[1:size(xs1, 1)]
			xs2 = vcat(xs[len+1] - 0.5, xs[len+1:end])
			ys2 = ys[1:size(xs2, 1)]
			plot!([xs1, xs2], [ys1, ys2], color=:red, linewidth=64^2 / 24 / lat.M * 1.5, label="")
		end			
	end
	for xy in lat.rods[2]
		xs = repeat([xy[2]], lat.L)
		ys = mod1.(xy[1]:xy[1]+lat.L-1, lat.M)
		continuous(v) = (dv = v[2:end] .- v[1:end-1];return all(dv[1] .== dv) && (abs(dv[1]) == 1))
		if continuous(ys)
			plot!(plt, xs, ys, color=:blue, linewidth=64^2 / 24 / lat.M * 1.5, label="")
		else
			len = 1 + lat.M - ys[1]
			ys1 = vcat(ys[1:len], ys[len] + 0.5)
			xs1 = xs[1:size(ys1, 1)]
			ys2 = vcat(ys[len+1] - 0.5, ys[len+1:end])
			xs2 = xs[1:size(ys2, 1)]
			plot!([xs1, xs2], [ys1, ys2], color=:blue, linewidth=64^2 / 24 / lat.M * 1.5, label="")
		end
	end
	display(plt)
end