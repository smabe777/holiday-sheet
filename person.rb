require 'json'
require 'set'
class Person
	attr_accessor :days, :first_name, :last_name, :holidays, :work_at_homes, :standbys
	def initialize (fname, lname, days = nil, hols = nil, wathomes =nil, stands = nil)
		@first_name = fname
		@last_name = lname
		if days.nil? then @days= {}
		else
			@days = days
		end
		if hols.nil? then @holidays= Set.new()
		else
			@holidays = hols
		end
		if wathomes.nil? then @work_at_homes = Set.new()
		else
			@work_at_homes = wathomes
		end
		if stands.nil? then @standbys = Set.new()
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
			"first_name" => @first_name,
			"last_name" => @last_name,
			"days" => days_to_json,
			"holidays" => @holidays.sort,
			"work_at_homes" => @work_at_homes.sort,
			"standbys" => @standbys
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