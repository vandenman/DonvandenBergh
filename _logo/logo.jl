using Luxor
import Random

Random.seed!(1234)
npoints = 1500
nchains = 8
xgrid   = range(-400, 400, length=npoints)
chains = zeros(npoints, nchains)
for j in 1:nchains
    chains[1, j] = 10 * randn()
    for i in 2:npoints
        chains[i, j] = 10 * (randn() + -chains[i - 1, j]/2000) + chains[i - 1, j]
    end
end

Drawing(800, 800, "luxor-drawing.svg")
origin()
background("white")
sethue("grey")
circle(Point(0, 0), 400, :fill)

hues = ["red", "blue", "green"]
setline(10)
for j in 1:nchains
    sethue(hues[j])
    for i in 1:npoints-1
        line(Point(xgrid[i], chains[i, j]), Point(xgrid[i+1], chains[i+1, j]), action=:stroke)
    end
end

finish()
preview()

Drawing(16, 16, "luxor-drawing.svg")
origin()

garishmesh = mesh(
    box(BoundingBox(), vertices=true),
    ["purple", "green", "yellow", "red"])

setmesh(garishmesh)

paint()

# setline(2)
# sethue("white")
# hypotrochoid(180, 81, 130, :stroke)
finish()
preview()

setline(2)
sethue("white")
hypotrochoid(180, 81, 130, :stroke)

sethue("grey")
circle(Point(0, 0), 400, :fill)

sethue("red")
setline(2)
for x in xgrid
    # move()
    line(Point(x, 100 * sin(x / 50)), Point(x, 100 * cos(x / 50)), action=:stroke)
    # stroke()
end

sethue("blue")
for x in xgrid
    # move()
    line(Point(x, 100 * cos(x / 50)), Point(x, 100 * sin(x / 50)), action = :stroke)
    # stroke()
end

finish()
preview()

# function draw_logo(filename)
resolution = 800
Drawing(resolution, resolution, "luxor-drawing.svg")
origin()
background("white")

xmin = -resolution ÷ 2
xmax = resolution ÷ 2
nlines = 81
step = (xmax - xmin) / 3nlines

amp = resolution ÷ 3
periods = 3 .* resolution .÷ [12, 9, 8]
amps = [amp, amp ÷ 2, amp ÷ 4]

xgrid1 =  range(xmin, xmax, nlines)
xgrid2 = xgrid1 .+ step
xgrid3 = xgrid1 .- step
xgrids = [xgrid1, xgrid2, xgrid3]
sethue("grey")
circle(Point(0, 0), resolution ÷ 2, :fill)

cols = ["red", "blue", "green"]
setline(8)

for i in eachindex(xgrids)
    sethue(cols[i])
    amp = amps[i]
    period = periods[i]
    for (j, x) in enumerate(xgrids[i])
        # sethue(cols[mod1(i + j, length(cols))])
        line(Point(x, amp * sin(x / period)), Point(x, amp * cos(x / period)), action=:stroke)
    end
end

finish()
preview()

using CairoMakie
using Colors
import Random
import Distributions

bg_color = Colors.colorant"#2b2434"
lcol1 = Colors.colorant"#44c5ff"
lcol2 = Colors.colorant"#f6f5ee"


-.5 + 1.5 / (1 + abs(x))
.5 - .2 * abs(x)
true_fun(x) =.5 - .2 * abs(x) + cospi(0.114 * 8 * x)

true_fun(x) =.5 - .3 * abs(x) + cospi(0.114 * 10 * x)

Random.seed!(1234)
# x = -5:0.01:5
x = range(-5, 5, length=201)
y = true_fun.(x)
ymin = y .- 1 .- randn(length(y)) * 0.1
ymax = y .+ 1 .+ randn(length(y)) * 0.1

for i in 2:length(y) - 1

    if y[i] < y[i-1] && y[i] < y[i+1]
        b = min(y[i-1], y[i+1])
        l = y[i] - 1.25
    else
        l, b = ymin[i-1], ymin[i+1]
        if l > b
            l, b = b, l
        end
    end
    ymin[i] = rand(Distributions.truncated(Distributions.Normal(y[i] - 1, .1), lower = l, upper = b))

    if y[i-1] < y[i] && y[i+1] < y[i]
        l = max(y[i-1], y[i+1])
        b = y[i] + 1.25
    else
        l, b = ymax[i-1], ymax[i+1]
        if l > b
            l, b = b, l
        end
    end
    ymax[i] = rand(Distributions.truncated(Distributions.Normal(y[i] + 1, .1), lower = l, upper = b))

end

col_range0 = range(lcol1, lcol2, length=(length(x) + 1) ÷ 2)
col_range = [col_range0[1:end-1]; lcol2; reverse(col_range0)[1:end-1]]

fig = Figure(size = (800, 800), backgroundcolor = bg_color)
ax = Axis(fig[1, 1], xlabel = "x", ylabel = "y", backgroundcolor = bg_color,
    limits = ((-5, 5), (-3, 3)))
hidedecorations!(ax)
hidespines!(ax)
band!(ax, x, ymin, ymax, color = col_range)
fig

# lines!(ax, x, y, color = :blue)
# band!(ax, x, ymin, ymax, color = :red, alpha = 0.5)

for i in eachindex(x)
    # vlines!(ax, x[i]; ymin = ymin[i], ymax = ymax[i], color = col_range[i], linewidth = 5)
    lines!(ax, [x[i], x[i]], [ymin[i], ymax[i]], color = col_range[i], linewidth = 5)
    # lines!(ax, Point2f(x[i], ymin[i]), Point2f(x[i], ymax[i]), color = col_range[i], linewidth = 5)
    # scatter!(ax, x[i], ymin[i], color = :red, markersize = 2)
    # scatter!(ax, x[i], ymax[i], color = :red, markersize = 2)
end

fig

# function draw_logo(filename)
resolution = 800
Drawing(resolution, resolution, "luxor-drawing.svg")
origin()
background(bg)

draw_area = resolution * 3 // 4
xmin = -resolution ÷ 2
xmax = resolution ÷ 2
nlines = 81
step = (xmax - xmin) / 3nlines

amp = resolution ÷ 2
period = 0.114
xgrid1 =  range(xmin, xmax, nlines)
xgrids = [xgrid1]#, xgrid2, xgrid3]

# sethue("grey")
# circle(Point(0, 0), resolution ÷ 2, :fill)

cols = ["blue", "blue", "green"]
setline(8)

for i in eachindex(xgrids)
    sethue(lcol1)
    for (j, x) in enumerate(xgrids[i])
        # sethue(cols[mod1(i + j, length(cols))])
        line(Point(x, amp * sin(x / period)), Point(x, amp * cos(x / period)), action=:stroke)
    end
end

finish()
preview()



sethue("red")
setline(2)
for x in xgrid
    # move()
    line(Point(x, 100 * sin(x / 20)), Point(x, 100 * cos(x / 20)), action=:stroke)
    # stroke()
end

sethue("blue")
for x in xgrid
    # move()
    line(Point(x, 100 * cos(x / 50)), Point(x, 100 * sin(x / 50)), action = :stroke)
    # stroke()
end

finish()
preview()
# end

draw_logo("/home/don/github/DonvandenBergh/_logo/logo.svg")



using Luxor
using MathTeXEngine
path_svg = "favicon.svg"
Drawing(100, 100, path_svg)
origin()
background("transparent")
fontsize(48)

x = 25#floor(Int, 50cos(π/4))
# grad = blend(Point(-x, x), Point(x, -x), "#FDBB2D", "#22C1C3")
# grad = blend(Point(-x, x), Point(x, -x), "#C0A080", "#5F9EA0")
grad = blend(Point(-x, x), Point(2x, -2x), "#845b45", "#E6CCBE")

setblend(grad)
circle(Point(0, 0), 50, action = :fill)
sethue("grey90")
t0 = L"\mathbb{D}\,\mathbb{B}"
text(t0, Point(-8, 6), halign=:center, valign=:middle, angle=0)
finish()


path_svg = "favicon_dark.svg"
Drawing(100, 100, path_svg)
origin()
background("transparent")
fontsize(48)

x = 25#floor(Int, 50cos(π/4))
# grad = blend(Point(-x, x), Point(x, -x), "#FDBB2D", "#22C1C3")
# grad = blend(Point(-x, x), Point(x, -x), "#C0A080", "#5F9EA0")
grad = blend(Point(-x, x), Point(2x, -2x), "#845b45", "#E6CCBE")

setblend(grad)
circle(Point(0, 0), 50, action = :fill)
sethue("grey10")
t0 = L"\mathbb{D}\,\mathbb{B}"
text(t0, Point(-8, 6), halign=:center, valign=:middle, angle=0)
finish()

# grad = blend(Point(-50, 0), Point(50, 0), "gold4", "orange")
# grad = blend(Point(-x, x), Point(x, -x), "gold4", "dodgerblue")

# grad = blend(Point(-x, x), Point(x, -x), "#fcff9e", "#c67700")

# linear-gradient(90deg, #FDBB2D 0%, #22C1C3 100%)
# linear-gradient(90deg, #fcff9e 0%, #c67700 100%)
