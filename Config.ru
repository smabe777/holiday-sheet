require_relative 'HolidaySheetView'
#--------------------------------------------------------------------
# This configuration file will be called by Rackup, a tool that takes the responsibility
# to start the web server with the configuration we specify and the 'callable' object we decide to run
#-------------------------------------------------------------------
# ######\ -s Puma
#use Rack::Reloader, 0
#use Rack::ContentLength

use Rack::Static, :urls => ["/static"]
run HolidaySheetViewRack.new