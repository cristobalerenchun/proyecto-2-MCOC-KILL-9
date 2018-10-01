using LightXML 
using Dates

xdoc_in = parse_file("Satelite.xml")

Earth_Explorer_File= root(xdoc_in) 
#println(name(Earth_Explorer_File))

header_list = Earth_Explorer_File["Earth_Explorer_Header"]
header = header_list[1]
#println(header)

data_block = Earth_Explorer_File["Data_Block"][1]
List_of_OSVs = data_block["List_of_OSVs"][1]


Nt_texto = attribute(List_of_OSVs, "count")
Nt = parse(Int32, Nt_texto) 
#println("Nt = $(Nt)")
t = zeros(Nt)
Z = zeros(6, Nt)

i = 1
for hijo in child_nodes(List_of_OSVs)
	global i
	

	if is_elementnode(hijo)
		nombre = name(hijo)

		if nombre == "OSV"
			
			utc_texto = content(XMLElement(hijo)["UTC"][1])
			utc_time = Dates.DateTime(utc_texto[5:end], "yyyy-mm-ddTHH:MM:SS.ssssss")
			UnixTime = Dates.datetime2unix(DateTime(utc_time))
			#println("i = $(i) utc_texto = $(utc_texto) now = $(now)")
			t[i] = UnixTime
			Z[1,i] = parse(Float64, content(XMLElement(hijo)["X"][1]))
			Z[2,i] = parse(Float64, content(XMLElement(hijo)["Y"][1]))
			Z[3,i] = parse(Float64, content(XMLElement(hijo)["Z"][1]))
			Z[4,i] = parse(Float64, content(XMLElement(hijo)["VX"][1]))
			Z[5,i] = parse(Float64, content(XMLElement(hijo)["VY"][1]))
			Z[6,i] = parse(Float64, content(XMLElement(hijo)["VZ"][1]))
			i += 1
		end	
	end
end

#println(Z)

z0 = [Z[1,1],Z[2,1],Z[3,1],Z[4,1],Z[5,1],Z[6,1]]
println(z0)


Mt = 5.972e24 #kg
G = 6.67408e-11
omega = -7.2921150e-5 #radians per SI seconds
Nt = 9000
dt = 10
t = range(0, step=dt, stop=(Nt-1)*dt)
z = z0


function zpunto(t, z) 
	x = z[1:3]
	xp = z[4:6]

	c = cos.(omega*t)
	s = sin.(omega*t)

	T = [c s 0; -s c 0; 0 0 1]
	Tp = omega*[-s c 0; -c -s 0; 0 0 0]
	Tpp = omega*2*[-c -s 0; s -c 0; 0 0 0]

	r = sqrt(x'*x)
	rnorm = T'x/r 

	Fg = -T'*(G*Mt/r^2 * rnorm + (Tpp*x + 2*Tp*xp))
	zp = zeros(6)
	zp[1:3] = xp 
	zp[4:6] = Fg
	return zp
end 

#println("zfinal = $(z[:,end])")

tiempo = zeros(Nt+1)

z = zeros(6,Nt+1)
z[:,1] = z0
tiempo[1] = t[1]

NSubSteps = 200

dt_sub = dt / NSubSteps

#Runge Kutta orden 4
for i in 2:(Nt+1)
	# println("paso $(i)")
	zsub = z[:,i-1]
	for substep in 1:NSubSteps
		k1 = zpunto(tiempo[i-1],zsub)
		k2 = zpunto(tiempo[i-1]+dt_sub*0.5, zsub + dt_sub*0.5*k1)
		k3 = zpunto(tiempo[i-1] + dt_sub*0.5, zsub + dt_sub*0.5*k2)
		k4 = zpunto(tiempo[i], zsub + dt_sub*k3)
		zsub = zsub + dt_sub*0.16*(k1 + 2k2 + 2k3 + k4)
    end
    z[:,i] = zsub
    tiempo[i] = tiempo[i-1] + dt
end
xdoc = XMLDocument()

xroot = create_root(xdoc,"Earth_Explorer_File")

xs1 = new_child(xroot, "Data_Block")
set_attribute(xs1, "type", "XML")


xs2 = new_child(xs1, "List_of_OSVs")
set_attribute(xs2, "count", "$(Nt)")

for i in 1:Nt 

	#t_datetime = Dates.unix2datetime(tiempo[i])
	t_datetime = Dates.DateTime(2018,8,14,22,59,32)+Dates.Second(10*i)
	t_utc = Dates.format(t_datetime, "yyyy-mm-ddTHH:MM:SS.ssssss")
	#println(t_utc)

	xs3 = new_child(xs2, "OSV")
	xs4 = new_child(xs3, "UTC")
	add_text(xs4,"UTC = $(t_utc)") 
	

	xs4 = new_child(xs3, "X")
	set_attribute(xs4, "unit", "m")
	add_text(xs4, "$(z[1,i])")

	xs4 = new_child(xs3, "Y")
	set_attribute(xs4, "unit", "m")
	add_text(xs4, "$(z[2,i])")

	xs4 = new_child(xs3, "Z")
	set_attribute(xs4, "unit", "m")
	add_text(xs4, "$(z[3,i])")

	xs4 = new_child(xs3, "VX")
	set_attribute(xs4, "unit", "m/s")
	add_text(xs4, "$(z[4,i])")

	xs4 = new_child(xs3, "VY")
	set_attribute(xs4, "unit", "m/s")
	add_text(xs4, "$(z[5,i])")

	xs4 = new_child(xs3, "VZ")
	set_attribute(xs4, "unit", "m/s")
	add_text(xs4, "$(z[6,i])")
end

# save to an XML file
save_file(xdoc, "orbitaPM2.xml")

println(xdoc)









