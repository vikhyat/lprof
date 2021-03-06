lprof - Line-wise profiling for Ruby
====================================

Usage
-----

    lprof.rb FILENAME [RANGE] [--time]

* FILENAME is the name of the file to be profiled.
* RANGE is the range of line-numbers to be profiled. It should be of the form `a..b` where `a` and `b` are the lower and upper line-numbers.
* If `--time` is included, the time taken by each step (in milliseconds) is also measured. Including this significantly increases the time taken by the profiling.

Example
-------

`cat input | ./lprof.rb example.rb --time` gives the following output:

     --------------------------
     LINE-WISE PROFILING REPORT
     --------------------------
         1 (   0.00) | small_primes = [2,3,5]
         1 (   0.00) | 
         1 (   0.00) | # save 3401 small primes
         1 (  64.65) | 7.upto(31622) do |i|
     31616 (  19.67) |   next if (i%6!=1) and (i%6!=5)
     10539 (  33.66) |   c = Math::sqrt(i).ceil
     10539 (  18.49) |   prime = true
     10539 ( 300.17) |   small_primes.each do |p|
    155807 ( 263.85) |     break if p > c
    152409 (  12.45) |     if i % p == 0
      7141 (  12.32) |       prime = false
      7141 (   0.00) |       break
         0 ( 253.64) |     end
    145268 (  23.06) |   end
     10539 (  18.30) |   small_primes << i if prime
     10539 (   0.00) | end
         1 (   0.00) | 
         1 (   0.07) | lower = gets.to_i
         1 (   0.00) | upper = gets.to_i
         1 (   0.00) | 
         1 (   0.01) | sieve = Hash.new(true)
         1 (   0.37) | small_primes.each do |p|
       140 (   0.28) |   break if p*p > upper
       139 (   0.28) |   n = (p >= lower) ? 2*p : lower+((p-lower%p)%p)
       139 ( 818.03) |   n.step(upper, p) {|i| sieve[i] = false }
       139 (   0.01) | end
         1 (   0.00) | 
         1 (1439.66) | (upper-lower+1).times do |i|
    530866 ( 172.71) |   if sieve[lower+i]
     41546 ( 248.42) |     puts lower+i
     41546 (1646.41) |   end
    530866 (   0.00) | end

`cat input | ./lprof.rb example.rb` gives the following output:

    --------------------------
    LINE-WISE PROFILING REPORT
    --------------------------
         1 | small_primes = [2,3,5]
         1 | 
         1 | # save 3401 small primes
         1 | 7.upto(31622) do |i|
     31616 |   next if (i%6!=1) and (i%6!=5)
     10539 |   c = Math::sqrt(i).ceil
     10539 |   prime = true
     10539 |   small_primes.each do |p|
    155807 |     break if p > c
    152409 |     if i % p == 0
      7141 |       prime = false
      7141 |       break
         0 |     end
    145268 |   end
     10539 |   small_primes << i if prime
     10539 | end
         1 | 
         1 | lower = gets.to_i
         1 | upper = gets.to_i
         1 | 
         1 | sieve = Hash.new(true)
         1 | small_primes.each do |p|
       140 |   break if p*p > upper
       139 |   n = (p >= lower) ? 2*p : lower+((p-lower%p)%p)
       139 |   n.step(upper, p) {|i| sieve[i] = false }
       139 | end
         1 | 
         1 | (upper-lower+1).times do |i|
    530866 |   if sieve[lower+i]
     41546 |     puts lower+i
     41546 |   end
    530866 | end


`cat input | ./lprof.rb example.rb 10..12` gives the following output:

     --------------------------
     LINE-WISE PROFILING REPORT
     --------------------------
    152409 |     if i % p == 0
      7141 |       prime = false
      7141 |       break

Installation
------------

All the work is done by `lprof.rb`, to install just drop that file somewhere in your `PATH`.
