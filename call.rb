#!/usr/bin/env ruby
# encoding: UTF-8
require './graph.rb'
require 'pp'

es = []
DATA.readlines.each do |ln|
  ns = ln.split.map(&:to_sym)
  v = ns.shift
  if ns.empty?
    es << [v]
  else
    ns.each{|it| es << [v, it]}
  end
end

g = Graph.new(es, true)
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
shirt belt tie
belt jacket
tie jacket
