small_primes = [2,3,5]

# save 3401 small primes
7.upto(31622) do |i|
  next if (i%6!=1) and (i%6!=5)
  c = Math::sqrt(i).ceil
  prime = true
  small_primes.each do |p|
    break if p > c
    if i % p == 0
      prime = false
      break
    end
  end
  small_primes << i if prime
end

lower = 123456
upper = 654321

sieve = Hash.new(true)
small_primes.each do |p|
  break if p*p > upper
  n = (p >= lower) ? 2*p : lower+((p-lower%p)%p)
  n.step(upper, p) {|i| sieve[i] = false }
end

(upper-lower+1).times do |i|
  puts lower+i if sieve[lower+i]
end
