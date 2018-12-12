require_relative './HolidaySheet'

def create_person_interface_1 (person_folder, name)
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

# def cumul_td(memo, date, datetype,person_date_id)
#     puts date
#     puts datetype.printmetoo ' '
#     memo=memo+"<tr><td>#{date}</td>\n"
#     if datetype.holiday?
#              memo=memo+"<td><label class=\"container\">#{date}<input id=\"holiday_#{person_date_id}\" type=checkbox checked /><span class=\"checkmark\"></span></label></td>\n"
#              memo=memo+"<td><label class=\"container\">#{date}<input id=\"athome_#{person_date_id}\" type=checkbox  /><span class=\"checkmark\"></span></label></td>\n"
#         elsif !datetype.holiday?
#             memo=memo+"<td><label class=\"container\">#{date}<input id=\"holiday_#{person_date_id}\" type=checkbox /><span class=\"checkmark\"></span></label></td>\n"
#             memo=memo+"<td><label class=\"container\">#{date}<input id=\"athome_#{person_date_id}\" type=checkbox checked /><span class=\"checkmark\"></span></label></td>\n"
#         else
#              puts datetype.holiday?.class
#             raise 'FU'
#         end

#     memo=memo+"<td>TBD</td></tr>\n"

# end

def cumul_td(memo, date, datetype,person_date_id)
    puts date
    puts datetype.printmetoo ' '
    memo=memo+"<tr><td>#{date}</td>\n"

    if datetype.holiday?
             memo=memo+"<td><input class=\"radio\" id=\"holiday_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" checked=true onclick=\"radio_clicked('holiday_#{person_date_id}')\"/><label class=\"label\">Holiday</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"athome_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\"  onclick=\"radio_clicked('athome_#{person_date_id}')\" /><label class=\"label\"/>Work-At-Home</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"onsite_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\"  onclick=\"radio_clicked('onsite_#{person_date_id}')\"/><label class=\"label\" />Work-On-Site</label></td>\n"
    else 
             memo=memo+"<td><input class=\"radio\" id=\"holiday_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" onclick=\"radio_clicked('holiday_#{person_date_id}')\"/><label class=\"label\">Holiday</label>\n"
             memo=memo+"<input class=\"radio\" id=\"athome_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" checked=true onclick=\"radio_clicked('athome_#{person_date_id}')\"/><label class=\"label\" >Work-At-Home</label>\n"
       memo=memo+"<input class=\"radio\"  id=\"onsite_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\" onclick=\"radio_clicked('onsite_#{person_date_id}')\"/><label class=\"label\" >Work-On-Site</label></td>\n"
        end

    memo=memo+"<td>#{datetype.standby?}</td></tr>\n"

end
def create_person_interface(person_folder, name)
    person = HolidaySheet.new(person_folder).load_person_by_name(name)
    memo =""
    base_id = person.first_name + "_" + person.last_name + "_" 
    person.days.each{
        |date, type| 
        person_date_id = base_id + date.to_s
        memo = cumul_td memo, date, type , person_date_id
    }
    holidays = memo
    #print holidays
     html_file = person_folder + "/" + person.first_name + "_" + person.last_name + ".html"
    html_template = person_folder +'/person_interface.html'

    html = File.read(html_template)

    new_html = html.gsub(/@@FNAME@@/, person.first_name)
                    .gsub(/@@LNAME@@/, person.last_name)
                    .gsub(/@@TABLE@@/, holidays)
    
    File.open(html_file, "w") do |f|
        f.write(new_html)
	end
end
create_person_interface './persons', 'Bebe Cioffi'