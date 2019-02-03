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
	def fullName
		@first_name + ' ' + @last_name
	end 
	def full_name
		@first_name + '_' + @last_name
	end 
	def add_date_if_new(date)
		if !@days.has_key?(date)
			@days[date] = DayType.new()
		end
	end 
	def check_public_holidays_and_WE (date)
		if (!Calendar.workday? date) then raise 'Date ' + date + ' is not an official workday.' end
	end
	def set_work_at_home(date) 
		check_public_holidays_and_WE date
		add_date_if_new date
		@days[date].set_work_at_home()
		@days[date].unset_holiday()
		@holidays.delete(date)
		@work_at_homes << date #DateUtils.to_date(date)
	end
	def set_holiday (date)
		check_public_holidays_and_WE date
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
		if !@days.has_key?(date) then return #work days are assumed
		else
			if (@days[date].no_standby?) # remove : no use to keep this in the list
				@days.delete(date)
			else #we need to keep the date, set it as work on site
				@days[date].set_workday()
			end
		end
	end
	def set_standby(date, starttime, endtime)
		#TODO : if standby is on workday, then hours should be out of office hours
		#		otherwise, standby should be on official holiday or weekends
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
							"standby" => type.standby
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
		jsonH["days"].each { |h| days[ h["date"] ] = DayType.new(h["characteristics"],"json")}
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
	  def update(hash_date_type, type_labels) #{"20181120" => "onsite"}, ['onsite','holiday','athome','standby']
		hash_date_type.each {
			|date, type|
			if type == type_labels[0] then set_workday(date)
			elsif type == type_labels[1] then set_holiday(date)
			elsif type == type_labels[2] then set_work_at_home(date)
			else throw 'Person:update --> unrecognized type'
			end
		}
	  end

end