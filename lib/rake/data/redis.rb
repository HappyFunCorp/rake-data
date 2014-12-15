require 'redis'
require 'rake/data'

# redis ||= Redis.new

def redis
  @redis ||= Redis.new
end

def redis_dump_sorted_set dest, dep, set, starting_index = 0, ending_index = -1
  task dest => dep do
    mkdir_p dest.to_s.pathmap( "%d" )
    puts "zrevrange #{set} > #{dest}"
    CSV.open( dest.to_s, "wb" ) do |out|
      results = redis.zrevrange set, starting_index, ending_index, with_scores: true
      results.each do |r|
        out << r
      end
    end
  end
end