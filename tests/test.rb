require_relative '../HolidaySheet'

def testPerson
	p = Person.new('Bill','Boket')
	p.set_work_at_home('20181119')
	p.set_workday('20181119')
	p.set_work_at_home('20181120')
	p.set_holiday('20181226')
	p.printme
	return p
end 

def testJSON
	person = testPerson
	File.open("file_json_complete.json", "w") do |f|
   f.write(person.to_json)
	end
end

def testJSONRead
	person = testPerson
	File.open("file_json_complete.json", "r") do |f|
		f.each_line do |line|
			puts line
			p = Person.create_from_json(line)
			p.printme
		end
	end
end
#testJSON

#person = testPerson

# pp = Person.create_from_json(person.to_json)

# puts
# pp.printme
# puts "-----------------"
# puts

###testJSONRead



def load_csv (csv_file)
	ret = []
	File.open(csv_file, "r") do |f|
		f.each_line do |line|
			#puts line
			ret << line.split(';')
		end
	end
	return ret
end 

def get_feries
	feries = load_csv("./analysis/feries.csv")
	official_holidays = []
	feries.each { |arr| official_holidays |= [arr[1]]	}
	Calendar.loadCalendar(official_holidays )
end 

#print DateUtils.date_rand Time.local(2018, 12, 1), Time.local(2019, 12, 31)

get_feries
puts

def test_days
	while (true)
		print "Enter date : "
		date=gets.chomp()
		dt = Date.parse(date)
		puts dt.strftime("%A %d/%m/%y")
		puts Calendar.workday?(dt)
		puts Calendar.holiday?(dt)
	end 
end

def rand_work_type person, date
	r = rand
	if(r < 0.33) then
		person.set_holiday(date)
	else
		person.set_work_at_home(date)
	end
end 
def generatePerson (fname, lname)
	p = Person.new(fname, lname)
	arr_dates = []
	(1..100).step(1) do |x|
		new_dt = Calendar.workday_date_rand(Time.local(2019, 1, 1), Time.local(2019, 12, 31)).strftime("%Y%m%d")
		arr_dates |= [ new_dt ]
		rand_work_type p, new_dt
	end
		File.open("../persons/" + p.first_name + "_" + p.last_name + ".json", "w") do |f|
	f.write(p.to_json)
	end
end

def generatePersons
	File.open("../People.txt", "r") do |f|
		f.each_line do |line|
			arr = line.split(' ')
			generatePerson arr[0], arr[1]
		end
	end
end 

def load_persons(person_folder)
	Dir[person_folder + "/*.json"].each {
		|json| 
		puts json		
		HolidaySheet.new(person_folder).load_person(json)
	}
end

#load_persons './persons'

def printPersons arr_persons
	print "----> size = #{arr_persons.length}"
	puts
	arr_persons.each {
		|x| print x.first_name + " " + x.last_name + " / "
    }
    puts
end 
def testPersonsforDates
	load_persons '../persons'
	(1..100).step(1) do |x|
		new_dt = Calendar.workday_date_rand(Time.local(2019, 1, 1), Time.local(2019, 12, 31)).strftime("%Y%m%d")
		print "date : " + new_dt
		puts
		puts "HOLIDAYS : "
		printPersons Calendar.peopleInHoliday(new_dt)
		puts
		puts '-------------------------'
		puts
		puts "WORK AT HOME : "
		printPersons Calendar.peopleWorkingAtHome(new_dt)
		puts
		puts "WORK ON SITE: "
		printPersons Calendar.peopleWorkingOnSite(new_dt)
		puts
		puts "=================================="
	end
end 

#generatePersons
#generatePerson 'Bill', 'Boket'
#generatePerson 'Julie', 'Nelson'
#testPersonsforDates

def testTeams

    holidaySheet = HolidaySheet.new('./persons','./html','./teams')
    zorros = Team.new("Zorros", [holidaySheet.load_person_by_name('Bill Boket'),
    holidaySheet.load_person_by_name('Edmund Zehr'),
    holidaySheet.load_person_by_name('Cyrus Vacca'),
    holidaySheet.load_person_by_name('Frederic Mizzell'),
    holidaySheet.load_person_by_name('Cesar Kestner'),
    holidaySheet.load_person_by_name('Arnoldo Hector'),
    holidaySheet.load_person_by_name('Jaime Bogart'),
    holidaySheet.load_person_by_name('Steven Metz')])
    
	printPersons zorros.persons
	holidaySheet.save_team zorros
    
    pharrels = Team.new("Pharrels", [holidaySheet.load_person_by_name('Roman Fuquay'),
    holidaySheet.load_person_by_name('Ronald Goodenough'),
    holidaySheet.load_person_by_name('Ashley Struthers'),
    holidaySheet.load_person_by_name('Oswaldo Melendez'),
    holidaySheet.load_person_by_name('Roberto Sandy'),
    holidaySheet.load_person_by_name('Kyle Johns'),
    holidaySheet.load_person_by_name('Bernard Utley')])
 
	printPersons pharrels.persons
	holidaySheet.save_team pharrels
    
    espumas = Team.new("Espumas", [holidaySheet.load_person_by_name('Murray Castelli'),
    holidaySheet.load_person_by_name('Sheldon Minner'),
    holidaySheet.load_person_by_name('Winston Adcox'),
    holidaySheet.load_person_by_name('Octavio Hoehne'),
    holidaySheet.load_person_by_name('Sylvester Holaway'),
    holidaySheet.load_person_by_name('Grady Perryman'),
    holidaySheet.load_person_by_name('Casie Desrosier')])

	printPersons espumas.persons
	holidaySheet.save_team espumas	

    bloopers = Team.new("Bloopers", [holidaySheet.load_person_by_name('Mercy Klopp'),
    holidaySheet.load_person_by_name('Berniece Fassett'),
    holidaySheet.load_person_by_name('Joeann Elridge'),
    holidaySheet.load_person_by_name('Chasity Schweizer'),
    holidaySheet.load_person_by_name('Ladawn Pelton'),
    holidaySheet.load_person_by_name('Maybell Dominick'),
    holidaySheet.load_person_by_name('Candelaria Knisely')])

    printPersons bloopers.persons
	holidaySheet.save_team bloopers

    edeles = Team.new("Edeles", [holidaySheet.load_person_by_name('Wen Braggs'),
    holidaySheet.load_person_by_name('Anette Marple'),
    holidaySheet.load_person_by_name('Twyla Delacerda'),
    holidaySheet.load_person_by_name('Louanne Kilgore'),
    holidaySheet.load_person_by_name('Bebe Cioffi'),
    holidaySheet.load_person_by_name('Leah Bost'),
    holidaySheet.load_person_by_name('Buena Graydon')])

	printPersons edeles.persons
	holidaySheet.save_team edeles

    lavenders = Team.new("Lavenders", [holidaySheet.load_person_by_name('Yun Schrage'),
    holidaySheet.load_person_by_name('Tammi Stogner'),
    holidaySheet.load_person_by_name('Erminia Sun'),
    holidaySheet.load_person_by_name('Bobbi Egbert'),
    holidaySheet.load_person_by_name('Jayna Delapp'),
    holidaySheet.load_person_by_name('Julie Nelson')])

	printPersons lavenders.persons
	holidaySheet.save_team lavenders

    return {:zorros => zorros, :pharrels => pharrels, :espumas => espumas, :bloopers => bloopers, :edeles => edeles, :lavenders => lavenders}

end 
require 'set'
def teamHolidays team
    persons = team.persons
    hols = Set.new()
    persons.each {
        |p| 
        hols |= p.holidays
    }
    puts '---------- ALL TEAM HOLIDAYS ---------------------'
    print hols
    puts
    puts '-------------------------------'
    hols.each{
        |date| print 'for date ' + date 
        printPersons Calendar.peopleInHoliday(date, team.persons)
        puts
        puts 'will be on holiday'
    }
end
teams_hash = testTeams
teamHolidays  teams_hash[:pharrels]

def loadTeamFromJSON team
	
    holidaySheet = HolidaySheet.new('./persons','./html','./teams')
	team = holidaySheet.load_team './teams/'+team+'.json'
	printPersons team.persons
end


loadTeamFromJSON 'Lavenders'
loadTeamFromJSON 'Pharrels'
loadTeamFromJSON 'Espumas'

