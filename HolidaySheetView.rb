require 'rack'
require_relative 'person_interface'

class HolidaySheetView < HolidaySheet
  attr_reader :request, :name

  def initialize(request, name, folder)
    super(folder)
    @name = name
    @request = request
  end

  def show 
        html_file = create_person_interface @person_folder, @name
        if html_file.nil? then return notFound @name end
        content = File.read(html_file)
        [200, {'Content-Type' => 'text/html', 'Content-Length' => content.size.to_s},[content] ]
  end
  
  def update (json)
        datetypes = JSON.parse( json)
        update_person(@name, datetypes, ['onsite','holiday','athome','standby']) 
        show
    end
    def notFound(what)
        content = "<h1>Requested content '"+ what+ "' not found</h1>"
        [404, {'Content-Type' => 'text/html', 'Content-Length' => content.size.to_s},[content] ]
    end 
end


app = Proc.new do |env|
    #name = "Bebe Cioffi"
    folder = './persons'
    request = Rack::Request.new(env)
    getname = request.path_info
    puts "Proc : getname = " + getname
    name = getname[1,100].gsub!('%20',' ')

    holidaySheetView = HolidaySheetView.new(request, name, folder)
    if  request.request_method == 'POST'
        json = request.body.read
        holidaySheetView.update json
    else
      holidaySheetView.show
    end 
end

 
app2 = Thread.new do |x|
    Rack::Handler::WEBrick.run app
end

app3 = Thread.new do |x|
        system('C:\Program Files (x86)\Google\Chrome\Application\chrome', 'http://localhost:8080/Bill%20Boket')
    # while (true) do
    # print 'what do you want ? '
    # response = gets.chomp
    # sleep(1)
    # end 
end
app2.join
#app3.join


