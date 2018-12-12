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
		@characteristics['workday']
	end
	def work_at_home?
		@characteristics['work_at_home']
	end
	def holiday?
		puts "here " + @characteristics['holiday'].to_s
		@characteristics['holiday'] 
	end
	def standby?
		@characteristics['standby']
	end
	def blank?
			#A blank day is an error -- the day should be completely dropped
		return (!workday? && !holiday? && !work_at_home? && !standby?);
	end
	def printmetoo (indent)
		resultstring = 'isworkday: ' + workday?.to_s()
		resultstring = 'SSSSS '  + @characteristics['holiday'].to_s
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
	def self.peopleInHoliday(date, team = nil)
		@@list_persons.select {
			|p| if team.nil? then 
				(p.holiday? date)
			else 
				(team.include? p) && (p.holiday? date)
			end 
			#|p| (p.holiday? date) && (	(team.include? p) unless team.nil? )
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

