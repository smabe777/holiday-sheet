require_relative './Calendar'
require_relative './person'
require_relative './team'
class HolidaySheet
    attr_accessor :person_folder
    def initialize (data_folder, html_folder)
        @person_folder = data_folder
        @html_folder = html_folder
    end
    def load_person(json_file)
        if !File.exist? json_file then return nil end
        content = File.read(json_file)
        p = Person.create_from_json(content)
        Calendar.addPerson p
        return p
    end 
    def update_person(fullname, hash_date_type, datetype_labels) #['onsite','holiday','athome','standby']
        p = load_person_by_name fullname
        p.update(hash_date_type, datetype_labels)
        save_person(p)
    end

    def save_person(p)
        json_file = @person_folder + "/" + p.first_name + "_" + p.last_name + ".json"
        File.open(json_file, 'w') do |f|
            f.write(p.to_json)
        end
    end

    def load_person_by_name(fullname)
        if !fullname.include? ' ' then  return nil end
        #if ! Calendar.personExists? fullname then return nil end
        names = fullname.split(' ')
        if( names.length() == 2) then
            json_file = @person_folder + "/" + names[0] + "_" + names[1] + ".json"
            #puts "to open file '#{json_file}'" 
            return load_person(json_file) 
        end
        return nil
    end
    def load_persons
        Dir[@person_folder + "/*.json"].each {
            |json| 
            puts json		
            load_person(json)
        }
    end

 end
