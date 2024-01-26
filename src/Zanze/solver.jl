using Random
using Plots
using Colors
using ColorSchemes



# Struktur
struct RodLat2D
	grid::BitArray
	rods::Vector{Vector{NTuple{2, Int64}}} # [horiz, vert]
	L::Int64
	M::Int64
	z::Float64 # z = exp(βμ)
	RodLat2D(M::Int64, L::Int64, z::Float64) = new(falses(M, M), [NTuple{2, Int}[], NTuple{2, Int}[]], L, M, z)
end



function visual(lat)
    grid = zeros(lat.M, lat.M)
    
    for horiz_rod in lat.rods[1]
       for i in 0:lat.L-1
            grid[mod1(horiz_rod[1], lat.M), mod1(horiz_rod[2]+i, lat.M)] = -1
       end 
    end
    for vert_rod in lat.rods[2]
        for i in 0:lat.L-1
            grid[mod1(vert_rod[1]-i, lat.M), mod1(vert_rod[2], lat.M)] = 1
        end
    end
    display(heatmap(grid, c = :RdGy_9, cbar=false))
    # heatmap(grid, cbar=false, c=palette([:orange, :white, :grey], 3), dpi=300)
    for i in 1:64
        for j in 1:64
            x = [j - 0.5, j + 0.5, j + 0.5, j - 0.5, j - 0.5]
            y = [i - 0.5, i - 0.5, i + 0.5, i + 0.5, i - 0.5]
            plot!(x, y, line=:black,legend=false, dpi=300, linewidth=0.5)
        end
    end
    display(plot!())
    # savefig("Verteilung.png")
end



# Kollisionscheck:
function check_for_collision(lat::RodLat2D, pos::NTuple{2, Int}, horizontal::Bool)
    
    # Check für horizontale Stäbchen
    if horizontal
        for i in 0:(lat.L-1)
            if lat.grid[pos[1], mod1(pos[2]+i, lat.M)]
                return true
            end
        end
        return false

    # Check für vertikale Stäbchen
    else
        for i in 0:(lat.L-1)
            if lat.grid[mod1(pos[1]-i, lat.M), pos[2]]
                return true
            end
        end
        return false
    end
end



# Einfügen von Stäbchen
function insertion!(lat::RodLat2D, pos::NTuple{2, Int}, horizontal::Bool)

    # Horizontales Einfügen
    if horizontal
        for i in 0:(lat.L-1)
            lat.grid[mod1(pos[1], lat.M), mod1(pos[2]+i, lat.M)] = 1
        end
        append!(lat.rods[1], [pos])
    
        # Vertikales Einfügen
    else
        for i in 0:(lat.L-1)
            lat.grid[mod1(pos[1]-i, lat.M), mod1(pos[2], lat.M)] = 1
        end
        append!(lat.rods[2], [pos])
    end
end



# Entfernen von Stäbchen
function deletion!(lat::RodLat2D, pos::NTuple{2, Int}, horizontal::Bool)

    # Horizontales Löschen (wenn horizontaler Bool gesetzt ist und Menge an horizontalen Stäbchen != {})
    if horizontal 
        for i in 0:(lat.L-1)
            lat.grid[mod1(pos[1], lat.M), mod1(pos[2]+i, lat.M)] = 0
        end

        # Entferne horizontales Stäbchen
        filter!(x -> x != pos, lat.rods[1])

    # Vertikales Löschen (wenn vertikaler Bool gesetzt ist und Menge an vertikalen Stäbchen != {})
    else
        for i in 0:(lat.L-1)
            lat.grid[mod1(pos[1]-i, lat.M), mod1(pos[2], lat.M)] = 0
        end

        # Entferne vertikales Stäbchen
        filter!(x -> x != pos, lat.rods[2])
    end
end



function start_simulation(lat::RodLat2D, steps::Int)
    arr = zeros(steps)
    for i in 1:steps

        # Gesamtanzahl Stäbchen
        N = size(lat.rods[1], 1) + size(lat.rods[2], 1)

        # Faktor, siehe S.7 im Skript. Kommt gleichermaßen in α_ins und α_del vor
        factor = 2 * lat.z * lat.M^2

        # 50/50 Einfügen oder Entfernen:
        # Einfügen
        if rand() <= 0.5

            # Einfügen

            # Wsk für Einfügen
            α_ins = factor/(N+1)
            
            # Random Position generieren
            rand_pos = (rand(1:lat.M),rand(1:lat.M))

            # 50/50 Horizontal oder Vertikal:
            # Horizontal 
            if rand() <= 0.5
                # Einfügen mit Wsk. α_ins falls es keine Kollision gibt
                if !check_for_collision(lat, rand_pos, true) && (rand() <= α_ins)
                    insertion!(lat, rand_pos, true)
                end

            # Vertikal
            else
                # Einfügen mit Wsk. α_ins falls es keine Kollision gibt
                if !check_for_collision(lat, rand_pos, false) && (rand() <= α_ins)
                    insertion!(lat, rand_pos, false)
                end
            end

        # Entfernen
        else
            # Wsk. zum Entfernen
            α_del = N/factor

            # Mit Wsk. α_del entfernen
            if rand() <= α_del

                # Wähle random aus ob horizontal oder vertikal
                rdm = bitrand()[1]

                # Wenn horizontal und Menge horizontaler Stäbchen != {}: entferne
                if rdm && lat.rods[1]!=[]
                    deletion!(lat, rand(lat.rods[1]), true)

                # Wenn vertikal und Menge vertikaler Stäbchen != {}: entferne
                elseif !rdm && lat.rods[2]!=[]
                    deletion!(lat, rand(lat.rods[2]), false)
                end
            end
        end
        arr[i] = (size(lat.rods[1], 1)-size(lat.rods[2], 1))/N
        # println(N)
        if i%10000==0
            println("#Horiz=",length(lat.rods[1]))
            println("#Verts=",length(lat.rods[2]),"\n")
            visual(lat)
        end
    end
    display(histogram(arr))
    return lat
end




test=RodLat2D(64, 8, 1.1)
test1=start_simulation(test, 4*100_000)
# display(test1.grid)
# display(test1.rods)
println(size(test1.rods[1], 1) + size(test1.rods[2], 1))
# visual(test1)