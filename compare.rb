# We can now track the ruby as it gets fed into the compiler
SCRIPT_LINES__ = {}

# Setup file_path variable
file_path = nil

# Default to only one benchmark
n = 1


# Requried: a file path at the end of the ARGVs
# Optional: -n : number of benchmarks to us
ARGV.each_with_index do |a, idx|  
  if a.to_s == "-n"
    n = ARGV[idx+1].to_i
  end
  
  if idx == ARGV.size-1
    file_path = a
  end
end

throw "A file path pointing to a .rb file is required" if file_path.nil?

# Bring in our solutions
require file_path

# And our benchmark tool
require 'benchmark'


# Some math methods
# TODO: I know there's a library for these...
def mean(ary)
  ary.inject(0) { |sum, i| sum += i }/ary.length.to_f 
end
def std_dev(ary, mean)
  Math.sqrt( (ary.inject(0) { |dev, i| 
                dev += (i - mean) ** 2}/ary.length.to_f) )
end

# Get our solutions
available_solutions = Solutions.singleton_methods.sort!

# Initialize a hash to hold the results
# { :john => [], :mark => [] }
all_times = available_solutions.inject({}){ |h,k| h.merge({k.to_sym => {:all => []}})}

# Do x number of benchmarks
# We randomize the order as we go
n.times do
  solutions = available_solutions.sort_by{ rand }

  bench = Benchmark.bmbm(10) do |x|
    solutions.each do |solution|
      x.report("#{solution}") { Solutions.send("#{solution}") }
    end
  end

  # Add the times into all_times
  bench.each_with_index do |b, idx|
    all_times[solutions[idx].to_sym][:all] << b.format("%r").gsub(/(\(|\))/, "").to_f
  end
end

all_times.each_pair do |k,v|
  avg =  mean(v[:all])
  sd = std_dev(v[:all], avg)
  
  all_times[k][:avg] = avg
  all_times[k][:std_dev] = sd
end

# Start putting together results
# Includes:
#   * Output from each solution
#   * Best Average
#   * All Averages
#   * Performance difference between Best and Worst method
#   * Most Stable (based on Std Dev)
#   * All Std Devs
results = ""

results << "Results \r\n"
available_solutions.each do |solution|
  results << "#{solution}: #{Solutions.send(solution)}\r\n"
end

results << "-------\r\n"

results << "Benchmarks: #{n}"

results << "\r\n-------\r\n"

best_avg = all_times.to_a.sort_by{ |a| a.last[:avg] }
best_sd = all_times.to_a.sort_by{ |a| a.last[:std_dev] }

results << "Best Average: #{best_avg.first.first} (#{best_avg.first.last[:avg]})"

results << "\r\n-------\r\n"
results << "All Averages\r\n"
best_avg.each { |a| results << "#{a.first}: #{a.last[:avg]}\r\n" }

diff = best_avg.last.last[:avg]/best_avg.first.last[:avg]
results << "-------\r\n"
results << "Difference Between Best Method and Worst Method (based on average time): A factor of #{format("%f", diff)}. (Meaning the best method is about #{diff.round}x better than the worst)"


results << "\r\n-------\r\n"
results << "Most Consistent (based on Std Dev): #{best_sd.first.first} (#{format("%f", best_avg.first.last[:std_dev])})"

results << "\r\n"
results << "All Standard Deviations\r\n"
best_sd.each { |a| results << "#{a.first}: #{format("%f", a.last[:std_dev])}\r\n" }

# Output results to file
file_name = file_path.to_s.split("/").last
file_dirs = file_path.to_s.split("/") - [file_name]
File.open(file_dirs.join("/") + "/results.txt", "w+") do |file|
  file.puts results
end

# Outputs results to console
# Also output the whole solutions.rb file to console
puts "=" * 100

puts "\r\n"
SCRIPT_LINES__["./" + file_path].each do |line|
    puts "#{line}"
end
puts "\r\n"

results.split("\r\n").each { |r| puts r }



