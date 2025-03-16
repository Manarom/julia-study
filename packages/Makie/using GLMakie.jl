using GLMakie

seconds = 0:0.1:2
measurements = [8.2, 8.4, 6.3, 9.5, 9.1, 10.5, 8.6, 8.2, 10.5, 8.5, 7.2,
                8.8, 9.7, 10.8, 12.5, 11.6, 12.1, 12.1, 15.1, 14.7, 13.1]
f = Figure() 
ax_left = Axis(f[1, 1],title="left axes")
ax_right = Axis(f[1, 2], aspect = 1)
l1=lines!(ax_left,seconds, measurements)
l2 = scatter!(ax_right,seconds,measurements)
ax_right.title = "title"

save("fig1.png",f) # save to file
f # shows the figure
set_theme!(backgroundcolor = :gray90)

display(GLMakie.Screen(), f) # creates new window to display graph
colsize!(f.layout, 1, Aspect(1, 1.0))

resize_to_layout!(f) # resized the layout to 
current_figure()

f = Figure()
for i in 1:5, j in 1:5
    Axis(f[i, j], width = 150, height = 150)
end
f
resize_to_layout!(f) # adjust the figure size to the size that the layout needs for all its content.

using GLMakie, GLMakie.FileIO, GeometryBasics

m = load(GLMakie.assetpath("cat.obj"))
GLMakie.mesh(m; color=load(GLMakie.assetpath("diffusemap.png")), axis=(; show_axis=false))