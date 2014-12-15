require 'rake/data/dsl'

data_rule ".html", ".htmlp" do |task|
  puts "Stripping outer function #{task.source} -> #{task}"
  in_file = File.read( task.source )
  in_file.gsub!( /\$\(.*\).html\('/m, "<div>" )
  in_file.gsub!( /'\);/, "</div>" )
  in_file.gsub!( /\\n/, "\n" )
  in_file.gsub!( /\\"/, "\"")
  in_file.gsub!( /\\'/, "'" )
  in_file.gsub!( /\\\//, "/" )
  mkdir_p task.to_s.pathmap( "%d" )
  File.open( task.to_s, "wb" ) { |out| out.puts in_file }
end

# This assumes that the callback name is the same as the action name
# weather.jsonp has a callback function of "weather"
# weather.my_func.jsonp has a callback function of "my_func"
data_rule ".json", ".jsonp" do |task|
  puts "Stripping outer function #{task.source} -> #{task}"

  if task.source =~ /([^\/.]*).jsonp/
    function_name = $1
    # puts "Funciton name #{function_name}"
    in_file = File.read( task.source )
    in_file.gsub!( /#{function_name}\(\s*/m, "" )
    in_file.gsub!( /\s*\);/, "" )

    mkdir_p task.to_s.pathmap( "%d" )
    File.open( task.to_s, "wb" ) { |out| out.puts in_file }
  else
    raise "When using the jsonp rule you need to put the callback in the name"
  end
end