#!/usr/bin/env ruby
# encoding: UTF-8
require './graph.rb'
require 'pp'

adjs = DATA.readlines.map{|ln| ln.split.map(&:to_sym) }
g = Graph.new(adjs, true)
puts g
p g.tsort
=begin
g.breadth_first_search(0)
print 'path: '
g.print_path(0, 15)
=end
__END__
undershorts pants shoes
socks shoes
watch
pants shoes belt
shoes
shirt belt tie
belt jacket
tie jacket
jacket
