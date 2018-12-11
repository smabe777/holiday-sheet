require_relative './HolidaySheet'

def create_person_interface (person_folder, name)
    person = HolidaySheet.new(person_folder).load_person_by_name(name)
    holidays = person.holidays.inject(""){
        |memo,date| memo+"<input class=\"calendar\" id=\"holiday_#{person.first_name}_#{person.last_name}_#{date}\" type=\"date\" value=\"#{Date.parse(date).to_s}\"/>\n"
    }
    work_at_homes = person.work_at_homes.inject(""){
        |memo,date| memo+"<input class=\"calendar\" id=\"holiday_#{person.first_name}_#{person.last_name}_#{date}\" type=\"date\" value=\"#{Date.parse(date).to_s}\"/>\n"
    }
    html_file = person_folder + "/" + person.first_name + "_" + person.last_name + ".html"
    html_template = person_folder +'/person_interface.html'

    html = File.read(html_template)

    new_html = html.gsub(/@@FNAME@@/, person.first_name)
                    .gsub(/@@LNAME@@/, person.last_name)
                    .gsub(/@@HOLIDAYS@@/, holidays)
                    .gsub(/@@WORK_AT_HOMES@@/, work_at_homes)

    File.open(html_file, "w") do |f|
        f.write(new_html)
	end
end 

create_person_interface './persons', 'Bill Boket'