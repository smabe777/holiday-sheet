require 'rack' 

class MyApp
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def status
    if homepage?
      200
    else
      404
    end
  end

  def headers
    {'Content-Type' => 'text/html', 'Content-Length' => body.size.to_s}
  end

  def body
    content = if homepage?
      "Your IP: #{request.ip}"
    else
      "Page Not Found"
    end

    layout(content)
  end

  private

  def homepage?
    print request.path_info
    request.path_info == '/'
  end

  def layout(content)
%{<!DOCTYPE html>
<html lang="en">
  <head>

    <meta charset="utf-8">
    <title>Your IP</title>
  </head>
  <body>
    #{content}
  </body>
</html>}
  end
end

class MyApp::Rack
  def call(env)
    request = Rack::Request.new(env)
    my_app = MyApp.new(request)

    [my_app.status, my_app.headers, [my_app.body]]
  end
end

