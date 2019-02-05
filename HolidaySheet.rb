require_relative './Calendar'
require_relative './person'
require_relative './team'
class HolidaySheet
    attr_accessor :person_folder
    def initialize (data_folder, html_folder, team_folder)
        @person_folder = data_folder
        @html_folder = html_folder
        @team_folder = team_folder
        loadCalendar
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
    def load_teams
        Dir[@team_folder + "/*.json"].each {
            |json| 
            puts json		
            load_team(json)
        }
    end
    def load_team(json_file)
        if !File.exist? json_file then return nil end
        content = File.read(json_file)
        team = Team.create_from_json(content)
        team.person_names.each {|name| team.persons << load_person_by_name(name) }
        team
    end
    def save_team(team)
        json_file = @team_folder + "/" + team.name + ".json"
        File.open(json_file, 'w') do |f|
            f.write(team.to_json)
        end
    end
    def load_csv (csv_file)
        ret = []
        File.open(csv_file, "r") do |f|
            f.each_line do |line|
                ret << line.split(';')
            end
        end
        return ret
    end 
    def loadCalendar
        feries = load_csv("./analysis/feries.csv")
        official_holidays = []
        feries.each { |arr| official_holidays |= [arr[1]]	}
        Calendar.loadCalendar(official_holidays )
    end 
    def createPerson (fname, lname)
        p = Person.new(fname, lname)
        File.open( @person_folder +'/'+ p.first_name + "_" + p.last_name + ".json", "w") do |f|
            f.write(p.to_json)
        end
    end

 end
