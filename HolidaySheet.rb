require_relative './Calendar'
require_relative './person'
require_relative './team'
class HolidaySheet
    attr_accessor :person_folder
    def initialize (folder)
        @person_folder = folder
    end
    def load_person(json_file)
        content = File.read(json_file)
        p = Person.create_from_json(content)
        Calendar.addPerson p
        return p
    end 

    def load_person_by_name(fullname)
        names = fullname.split(' ')
        if( names.length() == 2) then
            json_file = @person_folder + "/" + names[0] + "_" + names[1] + ".json"
            #puts "to open file '#{json_file}'" 
            return load_person(json_file) 
        end
         
    end 
 end
