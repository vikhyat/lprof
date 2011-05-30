ferror = -> a { $stderr.puts('ERROR: '+a); exit(1) }

filename = ARGV[0]
code     = File.new(filename).readlines
range    = ARGV[1] || "1..#{code.length}"
variable = ARGV[2] || "$lprof0833_c"

# error-checking, and making range an array of two numbers
if range =~ /^(\d+)\.\.(\d+)$/
  range = range.split('..').map {|x| x.to_i }
  if range[0] > range[1]
    ferror["lower value must not be greater than second in the range: '#{range*'..'}'"]
  end
else
  ferror["range is incorrectly specified: '#{range}'"]
end
if variable[0] != "$"
  ferror["counting variable should begin with $: '#{variable}'"]
end

out = File.new(filename+'lp', 'w')

out.puts("#{variable} = Array.new(#{range[1]-range[0]+1}) { 0 }")
1.upto(code.length) do |line_number|
  if line_number >= range[0] and line_number <= range[1]
    out.puts "#{variable}[#{line_number-range[0]}] += 1"
  end
  out.puts code[line_number-1]
end

footer = [
  "$stderr.puts(' --------------------------')",
  "$stderr.puts(' LINE-WISE PROFILING REPORT')",
  "$stderr.puts(' --------------------------')",
  "ml = #{variable}.max.to_s.length"
]
range[0].upto(range[1]) do |line_number|
  footer << "$stderr.printf \"%\#{ml}d | \", #{variable}[#{line_number-range[0]}]"
  footer << "$stderr.puts '#{code[line_number-1].chomp}'"
end

out.puts footer
out.close

print `ruby #{filename}lp > /dev/null`
File.delete(filename+'lp')
