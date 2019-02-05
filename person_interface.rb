#require_relative './HolidaySheet'


def cumul_td(memo, date, datetype,person_date_id)
    #puts date
    #puts datetype.printmetoo ' '
    memo=memo+"<tr><td>#{date}</td>\n"

    if datetype.holiday?
             memo=memo+"<td><input class=\"radio\" id=\"holiday_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" checked=\"checked\" onclick=\"radio_clicked('#{person_date_id}','#{date}','holiday')\" /><label class=\"label\">Holiday</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"athome_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\"  onclick=\"radio_clicked('#{person_date_id}','#{date}','athome')\" /><label class=\"label\">Work-At-Home</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"onsite_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\"  onclick=\"radio_clicked('#{person_date_id}','#{date}','onsite')\" /><label class=\"label\">Work-On-Site</label></td>\n"
    elsif datetype.work_at_home?
             memo=memo+"<td><input class=\"radio\" id=\"holiday_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" onclick=\"radio_clicked('#{person_date_id}','#{date}','holiday')\" /><label class=\"label\">Holiday</label>\n"
             memo=memo+"<input class=\"radio\" id=\"athome_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" checked=\"checked\" onclick=\"radio_clicked('#{person_date_id}','#{date}','athome')\" /><label class=\"label\">Work-At-Home</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"onsite_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\" onclick=\"radio_clicked('#{person_date_id}','#{date}','onsite')\" /><label class=\"label\">Work-On-Site</label></td>\n"
    else 
             memo=memo+"<td><input class=\"radio\" id=\"holiday_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" onclick=\"radio_clicked('#{person_date_id}','#{date}','holiday')\" /><label class=\"label\">Holiday</label>\n"
             memo=memo+"<input class=\"radio\" id=\"athome_#{person_date_id}\" type=\"radio\" name=\"radio#{date}\" onclick=\"radio_clicked('#{person_date_id}','#{date}','athome')\" /><label class=\"label\">Work-At-Home</label>\n"
             memo=memo+"<input class=\"radio\"  id=\"onsite_#{person_date_id}\" type=\"radio\"  name=\"radio#{date}\" checked=\"checked\" onclick=\"radio_clicked('#{person_date_id}','#{date}','onsite')\" /><label class=\"label\">Work-On-Site</label></td>\n"

        end

    memo=memo+"<td>#{datetype.standby}</td></tr>\n"

end
def create_person_interface(person_folder, html_folder,  person)
   # person = HolidaySheet.new(person_folder, html_folder).load_person_by_name(name)
    if person.nil? then return nil end
    memo =""
    base_id = person.full_name + "_" 
    person.days.each{
        |date, type| 
        person_date_id = base_id + date.to_s
        memo = cumul_td memo, date, type , person_date_id
    }
    holidays = memo

    html_template = html_folder +'/person_interface.html'

    html = File.read(html_template)

    new_html = html.gsub(/@@FNAME@@/, person.first_name)
                    .gsub(/@@LNAME@@/, person.last_name)
                    .gsub(/@@TABLE@@/, holidays)
    
    new_html
end
def create_team_interface(team_folder, person_folder, html_folder)
    selectTeams = Dir[team_folder + "/*.json"].reduce {
        |html, file| 
        teamName = json[team_folder.length+1 ..-6]
        if !teamName.nil? then 
            html += sprintf("\n<br/><option>%s</option>", teamName)
        end
    }
    print selectTeams

    html = File.read(html_template)
    content = ""
    Dir[person_folder + "/*.json"].each {
        |json| 
        personName = json[person_folder.length+1 ..-6].gsub!('_',' ')
        if !personName.nil? then 
        content = content + sprintf("\n<br/><input type=\"checkbox\" class=\"checkbox\">%s</input>", personName)
        end
    }
    html_template = html_folder +'/team.html'

    html = File.read(html_template)
    new_html = html.gsub(/@@PERSONS_CHECKBOXES@@/, content)
                    .gsub(/@@TEAMS_OPTIONS@@/, selectTeams)
    
    new_html
end
