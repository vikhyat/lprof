#!/usr/bin/env ruby

# Takes care of fatal errors
def ferror(a)
  $stderr.puts('ERROR: '+a)
  exit(1)
end

filename = ARGV[0]
code     = File.new(filename).readlines
range    = ARGV[1] || "1..#{code.length}"
input    = $stdin.readlines.join.gsub("'", '\\\\\'')
variable = "$lprof0833_c"
ext      = "lp"

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
out.puts "#{variable} = Array.new(#{range[1]-range[0]+1}) { 0 }"

# write all the code to the temporary file, annotating where necessary
0.upto(code.length-1) do |line_number|
  if line_number >= range[0] and line_number <= range[1]
    # increment the counter for this line
    out.puts "#{variable}[#{line_number-range[0]}] += 1"
  end
  # execute this line
  out.puts code[line_number]
end

out.puts "$stderr.puts(' --------------------------')"
out.puts "$stderr.puts(' LINE-WISE PROFILING REPORT')"
out.puts "$stderr.puts(' --------------------------')"
out.puts "ml = #{variable}.max.to_s.length"

range[0].upto(range[1]) do |line_number|
  out.puts "$stderr.printf \"%\#{ml}d | \",#{variable}[#{line_number-range[0]}]"
  out.puts "$stderr.puts '#{code[line_number].chomp}'"
end

out.close

print `echo '#{input}' | ruby #{filename}#{ext} > /dev/null`
File.delete(filename+ext)
