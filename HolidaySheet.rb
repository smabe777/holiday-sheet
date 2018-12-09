require "json"
require "yaml"
class HolidaySheet
    attr_accessor : folder, person
    def initialize
    end



def to_yaml()
    File.open(@folder + "/" + @person, "w") do |file|
    file.puts YAML::dump(self)
    file.puts ""
end
def to_json(*a)
    {
      "json_class"   =&gt; self.class.name,
      "data"         =&gt; {"string" =&gt; @string, "number" =&gt; @number }
    }.to_json(*a)
end

 def self.json_create(o)
    new(o["data"]["string"], o["data"]["number"])
  end
 end

#Make sure to not forget to '_require_' json, otherwise you'll get funny behaviour. Now you can simply do the following:

#ruby
a = A.new("hello world", 5)
json_string = a.to_json
puts json_string
puts JSON.parse(json_string)```


  # Of course **you almost never want to serialize just one object**, 
  #it is usually an array or a hash. In this case you have two options, 
  #either you serialize the whole array/hash in one go, or you serialize 
  #each value separately. The rule here is simple, if you always need to work 
  #with the whole set of data and never parts of it, just write out the whole array/hash, 
  #otherwise, iterate over it and write out each object. 
  #The reason you do this is almost always to share the data with someone else.

#If you just write out the whole array/hash in one fell swoop then it is 
#as simple as what we did above. When you do it one object at a time, it is a 
#    little more complicated, since we don't want to write it out to a whole 
#    bunch of files, but rather all of them to one file. It is a little more
#     complicated since you want to be able to easily read your objects back in 
#     again which can be tricky as <span style="font-style: italic;">
#     </span>_YAML_ serialization creates multiple lines per object. 
#     Here is a trick you can use, when you write the objects out, separate them 
#     with two newlines e.g.:
