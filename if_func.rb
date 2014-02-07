#!/usr/bin/env ruby
# encoding: UTF-8

my_true = ->x,y{x}
my_false = ->x,y{y}
my_if = ->x,y,z{x[y,z]}
p my_if[my_true,1,2], my_if[my_false,1,2]
