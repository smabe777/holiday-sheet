require_relative './person'

class Team
    attr_accessor :name, :persons
    def initialize (name, persons)
        @name = name
        @persons = persons
    end 
    def print
        puts
        print "Team #{name} is composed of #{persons}"
        puts
    end 
end 