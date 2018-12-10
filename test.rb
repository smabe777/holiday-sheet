require_relative './Calendar.rb'
require_relative './person.rb'

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
	feries = load_csv("./feries.csv")
	official_holidays = []
	feries.each { |arr| official_holidays |= [arr[1]]	}
	Calendar.loadCalendar(official_holidays )
end 

print DateUtils.date_rand Time.local(2018, 12, 1), Time.local(2019, 12, 31)

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

		File.open("./persons/" + p.first_name + "_" + p.last_name + ".json", "w") do |f|
	f.write(p.to_json)
	end
end

def generatePersons
	File.open("./People.txt", "r") do |f|
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
		load_person(json)
	}
end
def load_person(json_file)
	content = File.read(json_file)
	p = Person.create_from_json(content)
	Calendar.addPerson p
	return p
end 


#load_persons './persons'

def printPersons arr_persons
	print "----> size = #{arr_persons.length}"
	puts
	arr_persons.each {
		|x| print x.first_name + " " + x.last_name + " / "
	}
end 
def testPersonsforDates
	load_persons './persons'
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
testPersonsforDates