require 'date'
require 'json'

class DayType
	attr_accessor :characteristics
	def initialize (chars = nil) 
		if chars.nil? then
			@characteristics={}
			unset_workday
			unset_holiday
			unset_work_at_home
			unset_standby
		else
			@characteristics=chars 
		end 
	end
	def set_workday
		#a workday cannot be a work-at-home or a holiday 
		# but it can have a standby associated, as standby will rather work on timeframes
		unset_work_at_home
		unset_holiday
		@characteristics['workday']=true
	end 
	def set_work_at_home
		unset_workday
		@characteristics['work_at_home']=true
	end
	def set_holiday
		unset_workday
		@characteristics['holiday']=true
	end 
	def set_standby (startt, endt)
		#this will be a time period
		@characteristics['standby']=[startt, endt]
	end 
	def unset_workday
		@characteristics['workday']=false
	end 
	def unset_work_at_home
		@characteristics['work_at_home']=false
	end
	def unset_holiday
		@characteristics['holiday']=false
	end  
	def unset_standby
		@characteristics['standby']=false
	end   
	def workday?
		return @characteristics['workday']
	end
	def work_at_home?
		return @characteristics['work_at_home']
	end
	def holiday?
		return @characteristics['holiday']
	end
	def standby?
		return @characteristics['standby']
	end
	def blank?
			#A blank day is an error -- the day should be completely dropped
		return (!workday? && !holiday? && !work_at_home? && !standby?);
	end
	def printmetoo (indent)
		resultstring = 'isworkday: ' + workday?.to_s()
		resultstring = resultstring + "\n"
		resultstring = resultstring + indent + 'isholiday: ' + holiday?.to_s()
		resultstring = resultstring + "\n"
		resultstring = resultstring + indent + 'iswork_at_home: ' + work_at_home?.to_s()
		resultstring = resultstring + "\n"
		resultstring = resultstring + indent + 'isstandby: ' + standby?.to_s()
		resultstring = resultstring + "\n"
		resultstring = resultstring + indent + 'isblank: ' + blank?.to_s()
		return resultstring 
	end
	def to_json(a)
       return {
			#"date" => @date.to_s,
			"characteristics" => {
				"workday" => @characteristics['workday'].to_s,
				"holiday" => @characteristics['holiday'].to_s,
				"work_at_home" => @characteristics['work_at_home'].to_s,
				"standby" => @characteristics['standby'].to_s
			}
        }.to_json
	end
end


class DateUtils
	def self.to_date(date) #format yyyymmdd
		#return Time.new(date[0..3],date[4..5],date[6..7])
		return Date.parse(date)
	end
	def self.time_rand (from = 0.0, to = Time.now)
		Time.at(from + rand * (to.to_f - from.to_f))
	end
	def self.date_rand (from = 0.0, to = Time.now)
		Date.parse(Time.at(from + rand * (to.to_f - from.to_f)).to_s)
	end
end
class Person
	attr_accessor :days, :first_name, :last_name
	def initialize (fname, lname, days = nil, hols = nil, wathomes =nil, stands = nil)
		@first_name = fname
		@last_name = lname
		if days.nil? then @days= {}
		else
			@days = days
		end
		if hols.nil? then @holidays= []
		else
			@holidays = hols
		end
		if wathomes.nil? then @work_at_homes = []
		else
			@work_at_homes = wathomes
		end
		if stands.nil? then @standbys = []
		else
			@standbys = stands
		end
	end

	def add_date_if_new(date)
		if !@days.has_key?(date)
			@days[date] = DayType.new()
		end
	end 
	def set_work_at_home(date) 
		add_date_if_new date
		@days[date].set_work_at_home()
		@days[date].unset_holiday()
		@holidays.delete(date)
		@work_at_homes << date #DateUtils.to_date(date)
	end
	def set_holiday (date)
		add_date_if_new date
		@days[date].set_holiday()
		@days[date].unset_work_at_home()
		@holidays << date # DateUtils.to_date(date)
		@work_at_homes.delete(date)
	end
	def holiday? (date)
		return @holidays.include? date
	end
	def work_at_home? (date)
		return @work_at_homes.include? date
	end
		
	def work_on_site? (date)
		return (Calendar.workday? date) && (!holiday? date) && (!work_at_home? date) 
	end
	def set_workday (date)
		#it is not needed to add a work day to a person
		#the default is that all days except official_holidays and WE are workdays
		#using set_workday only means that one had previously selected a holiday,
		#and then changed of idea
		if !@days.has_key?(date) then return #date should exist
		else
		@days[date].set_workday()
		#remove
		end
	end
	def set_standby(date, starttime, endtime)
		add_date_if_new date
		@days[date].set_standby(starttime, endtime)
		@standbys << [starttime, endtime] #Day.to_date(date)
	end
	def printme
		puts @last_name +', '+ @first_name
		puts '		holidays: ' + @holidays.to_s
		puts '		work_at_homes: ' + @work_at_homes.to_s
		puts '		standbys: ' + @standbys.to_s
		puts '		days :'
		@days.sort.each {|x,y| puts  '			' + x + " : " + y.printmetoo('				') }
	end
	def days_to_json
		ret = []
		@days.sort.each {|date,type| 
					ret << 
					{
						"date" => date, 
						"characteristics" => {
							"workday" => type.workday?.to_s,
							"holiday" => type.holiday?.to_s,
							"work_at_home" => type.work_at_home?.to_s,
							"standby" => type.standby?.to_s
						} 
					}
				};
		return ret
	end 
	def to_json
        {
			"first_name" => @first_name.to_s,
			"last_name" => @last_name.to_s,
			"days" => days_to_json,
			"holidays" => @holidays.sort.to_s,
			"work_at_homes" => @work_at_homes.sort.to_s,
			"standbys" => @standbys.to_s
        }.to_json
	end
	def self.create_from_json(json)
    	jsonH = JSON::parse(json)
		days = {}
		jsonH["days"].each { |h| days[ h["date"] ] = DayType.new(h["characteristics"])}
		pp = Person.new(
				jsonH["first_name"], 
				jsonH["last_name"], 
				days,
				jsonH["holidays"],
				jsonH["work_at_homes"],
				jsonH["standbys"]
				);
		return pp
  	end

end
class Calendar
	@@list_holidays = []
	@@list_persons = []
	def sprint_from_date(date)
	end
	def self.holiday?(dt_str)
		date = Date.parse(dt_str)
		@@list_holidays.include? date
	end
	def self.workday?(date_str)
		date = Date.parse(date_str)
		(!@@list_holidays.include? date) && (!date.saturday?) && (!date.sunday?)
	end
	def self.loadCalendar(list_hols) 
		list_hols.each {|date| @@list_holidays << Date.parse(date)}
	end
	def self.addPerson(person)
		@@list_persons << person
	end 
	def self.workday_date_rand(from, to)
		dt = DateUtils.date_rand(from, to) 
		return dt unless !workday?(dt.strftime('%Y%m%d')) 
		return workday_date_rand(from, to)
	end
	def self.peopleInHoliday(date)
		@@list_persons.select {
			|p| p.holiday? date
		}
	end 
	def self.peopleWorkingAtHome(date)
		@@list_persons.select {
			|p| p.work_at_home? date
		}
	end 
	def self.peopleWorkingOnSite(date)
		@@list_persons.select {
			|p| p.work_on_site? date
		}
	end 
end

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

generatePersons
testPersonsforDates
