#!/usr/bin/env ruby

# Takes care of fatal errors
def ferror(a)
  $stderr.puts('ERROR: ' + a)
  exit(1)
end

# replace 's with \'s
def escape_single_quotes(str)
  str.gsub("'", '\\\\\'')
end

if ARGV.include? "--time"
  measure_time = true
  ARGV.delete("--time")
else
  measure_time = false
end

filename      = ARGV[0]
code          = File.new(filename).readlines
range         = ARGV[1] || "1..#{code.length}"
input         = escape_single_quotes($stdin.readlines.join)
variable      = "$lprof0833_c"
time_variable = variable + "_t"
ext           = "lp"

# error-checking, and making range an array of two numbers
if range =~ /^(\d+)\.\.(\d+)$/
  range = range.split('..').map {|x| x.to_i-1 }
  if range[0] > range[1]
    ferror "lower value is greater than second in the range: '#{range*'..'}'"
  end
else
  ferror "range is incorrectly specified: '#{range}'"
end
if variable[0] != "$"
  ferror "counting variable should begin with $: '#{variable}'"
end

# create a temporary file to store annotated code
out = File.new(filename+ext, 'w')
out.puts "#{variable} = Array.new(#{range[1]-range[0]+1}) { [0, 0.0] }"

# write all the code to the temporary file, annotating where necessary
0.upto(code.length-1) do |line_number|
  in_range = true if line_number >= range[0] and line_number <= range[1]
  
  thisvar = "#{variable}[#{line_number-range[0]}]"
  out.puts  "#{thisvar}[0] += 1" if in_range
  out.puts  "#{time_variable} = Time.now" if measure_time and in_range
  out.puts  code[line_number]
  out.print "#{thisvar}[1] += " if measure_time and in_range
  out.puts  "(Time.now-#{time_variable})*1000" if measure_time and in_range
end

out.puts "$stderr.puts(' --------------------------')"
out.puts "$stderr.puts(' LINE-WISE PROFILING REPORT')"
out.puts "$stderr.puts(' --------------------------')"
out.puts "ml0 = #{variable}.map {|x| x[0] }.max.to_s.length"
out.puts "ml1 = #{variable}.map {|x| x[1].ceil }.max.to_s.length + 3"

range[0].upto(range[1]) do |line_number|
  out.print "$stderr.printf \"%\#{ml0}d "
  out.print "(%\#{ml1}.2f) " if measure_time
  out.puts "| \", *#{variable}[#{line_number-range[0]}]"
  out.puts "$stderr.puts '#{escape_single_quotes(code[line_number].chomp)}'"
end

out.close

print `echo '#{input}' | ruby #{filename}#{ext} > /dev/null`
File.delete(filename+ext)
