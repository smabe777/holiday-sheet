require 'rack'
require_relative 'person_interface'

#---------------------------------------------------------
#   HolidaySheetView
#
# This class inherits from HolidaySheet, the main application class that connects to
# Person and Calendar classes to ensure the content.
# HolidaySheetView is responsible to interact with the browser with 2 main responsibilities :
# show the current content and accept changes to that content.
# HTML interaction is provided through the Rack library that makes a request object available,
# and accepts a triplet : return_Code; headers ; body
#
#----------------------------------------------------------

class HolidaySheetView < HolidaySheet
  attr_reader :request, :name

  def initialize(request, name, data_folder, html_folder)
    super(data_folder, html_folder)
    @name = name
    @request = request
    
  end

  def show 
        html_file = create_person_interface @person_folder, @html_folder, @name 
        if html_file.nil? then return notFound @name end
        serveContent File.read(html_file)
  end
  def page (file)
    if File.extname(file) == '.css' then mime = 'text/css' 
    elsif File.extname(file) == '.js' then mime = 'text/javascript' 
    else mime = 'text/html' end
    serveContent File.read(file), mime
  end

  def update (json)
        datetypes = JSON.parse( json)
        begin
        update_person(@name, datetypes, ['onsite','holiday','athome','standby']) 
        serveContent "updated " + @name +" with '" + json +"'"
        rescue StandardError => e
            print e.message
            serveContent e.message
        end
    
    end
    def create (json)
        person = JSON.parse (json)
        createPerson(person["firstname"], person["lastname"])
        serveContent "to create '"+person["firstname"]+" "+ person["lastname"]+ "' with '" + json +"'"
    end 
    def notFound(what)
        content = "<h1>Requested content '"+ what+ "' not found</h1>"
        [404, {'Content-Type' => 'text/html', 'Content-Length' => content.size.to_s},[content] ]
    end 

    def serveContent content, type = 'text/html'
        [200, {'Content-Type' => type, 'Content-Length' => (content.size).to_s},[content] ]
    end 
 
    def listOfPersons
        content = ""
        Dir[@person_folder + "/*.json"].each {
            |json| 
            puts json
            personName = json[@person_folder.length+1 ..-6].gsub!('_',' ')
            if personName.nil? then 
                #throw "Internal error : filename '#{json}' could not be parsed." end
                content = content + sprintf("\n<br/><p style=\"color=red;\">ERROR FILE : %s<p/>", json)
            else

            content = content + sprintf("\n<br/><a href='%s%s'>%s<a/>", request.url, personName, personName)
            end
        }
        serveContent content
    end 
end

#---------------------------------------------------------
#   HolidaySheetViewRack
#
#This class is the main interface to the Rack library
#Rack acts between the server and the Ruby web framework
#It can also been used directly, as does this application
#the only condition is to provide an object answering to a method 'call'.
#(can be a Proc, a Lambda or a class with method call)
#--------------------------------------------------------------
class HolidaySheetViewRack
    def call env
            folder = './persons'
            html_folder = './html'
            request = Rack::Request.new(env)
            getname = request.path_info
            
            puts "getname = '#{getname}'"

            #---------------------------------------------------------------------
            # We expect the full name to be given as URI : '/Firstname%20Lastname'
            # We try stripping the %20 character
            #---------------------------------------------------------------------
            name = getname[1,100].gsub!('%20',' ')

            holidaySheetView = HolidaySheetView.new(request, name, folder, html_folder)


            #----------------------------------------------------------------------
            # any GET will be redirected to error if does not comply with '/Firstname%20Lastname',
            # or if the corresponding JSON file 'Firstname_Lastname.json' is not found on the server 
            # any POST is supposed to be JSON data giving pairs of date -> day_type
            #---------------------------------------------------------------------
                if  request.request_method == 'POST'
                    json = request.body.read
                    if (getname =='/NewUser') then
                        holidaySheetView.create json
                    else
                        holidaySheetView.update json
                    end
                else
                    
                if !name.nil? 
                        holidaySheetView.show

                else #if the name is not accepted, send list of persons
                    if(getname == '/') then holidaySheetView.listOfPersons 
                    elsif (getname !='/favicon.ico') then holidaySheetView.page html_folder + getname
                    else  holidaySheetView.notFound getname end
                end
            end 
    end
end

#--------------------------------------------------------
# We start the webserver in one thread, and in the other the webbrowser, so that client and server are fired
# at the same time for user satisfaction
#---------------------------------------------------------

webServerThread = Thread.new do |x|
    Rack::Handler::WEBrick.run HolidaySheetViewRack.new
end

webBrowserThread = Thread.new do |x|
        system('C:\Program Files (x86)\Google\Chrome\Application\chrome', 'http://localhost:8080/')
    # while (true) do
    # print 'what do you want ? '
    # response = gets.chomp
    # sleep(1)
    # end 
end
webServerThread.join
#app3.join


