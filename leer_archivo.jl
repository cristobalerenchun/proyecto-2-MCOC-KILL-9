using LightXML 
using Dates

function leer_archivo(xdoc_in) 
	xdoc_in = parse_file("Satelite.xml")

	Earth_Explorer_File= root(xdoc_in) 
	println(name(Earth_Explorer_File))

	header_list = Earth_Explorer_File["Earth_Explorer_Header"]
	header = header_list[1]
	println(header)

	data_block = Earth_Explorer_File["Data_Block"][1]
	List_of_OSVs = data_block["List_of_OSVs"][1]


	Nt_texto = attribute(List_of_OSVs, "count")
	Nt = 9000
	println("Nt = $(Nt)")
	t = zeros(Nt)
	Z = zeros(6, Nt)

	i = 1
	for hijo in child_nodes(List_of_OSVs)
		#global i
	

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
	return Z,t
end




