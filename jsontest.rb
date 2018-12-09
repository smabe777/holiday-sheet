class Province
	 attr_accessor :provOrigine, :destination, :total, 
                        :q1, :q2, :q3, :q4

        def initialize(line)
            @provOrigine =  line.split(';').first.split(",").first
            @destination =  line.split(';').at(1).split(',').first
            @q1 = (line.split(';').at(4)).to_i
            @q2 = (line.split(';').at(5)).to_i
            @q3 = (line.split(';').at(6)).to_i
            @q4 = (line.split(';').at(7)).to_i
        end
	def to_json(*a)
	{'provOrigine' => @provOrigine.to_s, 
	'destination' => @destination.to_s, 
	'q1' => @q1.to_s, 'q2' => @q2.to_s, 
	'q3' => @q3.to_s, 'q4' => @q4.to_s
	}.to_json(*a)

	end
end
prov_instances = [];
prov_instances << Province.new("Alberta,nil;somewhere;2;3;4;5;6;7");
prov_instances << Province.new("Terre-Neuve-et-Labrador,nil;somewhere;2;3;4;5;6;7");
prov_instances << Province.new("Nunavut,nil;somewhere;2;3;4;5;6;7");
prov_instances <<  Province.new("Île-du-Prince-Édouard,nil;somewhere;2;3;4;5;6;7");
File.open("file_json_complete.json", "w") do |f|
   f.write(prov_instances.to_json)
end