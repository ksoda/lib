#!/usr/bin/env ruby
# encoding: UTF-8
# Higher order functions - you learn haskell
p 100_000.downto(1).lazy.select {|i| i % 3829 == 0
}.first

p (1..Float::INFINITY).lazy.map{|i| i**2
}.select(&:odd?).take_while{|i| i < 10_000
}.inject(:+)
