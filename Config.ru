require './rack.rb'
#run Rack::Cascade.new [MyApp]
run MyApp::Rack.new