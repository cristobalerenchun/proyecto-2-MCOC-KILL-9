
include("leer_eof.jl")

file1 = ARGS[1]
file2 = ARGS[2]

println("File 1 is: $(file1)")
println("File 2 is: $(file2)")

t1,Z1 = leer_eof(file1)
t2,Z2 = leer_eof(file2)

# println(t2)

difft = maximum(t1[1:9000] - t2[1:9000])
diffX = Z1[1:3,1:9000] - Z2[1:3,1:9000]

Norm_diffX = sum(sqrt.(diffX .* diffX), dims=1)

# println("  Norm_diffX = $(Norm_diffX) ")

max_Norm_diffX = maximum(Norm_diffX)

println("diff t = $(difft)")
println("diff X = $(max_Norm_diffX)")