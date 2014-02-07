#!/usr/bin/env ruby
# encoding: UTF-8

N = 100
p (1..Float::INFINITY).lazy.map{|i|
  res = ''
  res = 'Fizz' if i % 3 == 0
  res += 'Buzz' if i % 5 == 0
  res = i if res.empty?
  res
}.first(N)
