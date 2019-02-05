require_relative './person'

class Team
    attr_accessor :name, :persons, :person_names
    def initialize (name, persons = [])
        @name = name
        @persons = persons
        @person_names = []
    end 
    def print
        puts
        print "Team #{name} is composed of #{persons}"
        puts
    end   
    def to_json
        person_names = []
        @persons.each {|p| person_names << p.first_name + ' ' + p.last_name }
        {
			"name" => @name,
			"persons" => person_names
        }.to_json
	end
    def self.create_from_json(json) 
        jsonH = JSON::parse(json)
        names = jsonH["persons"]
        team = Team.new(
				jsonH["name"]
                );
        team.person_names = names
        team
	  end
end 