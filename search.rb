#!/usr/bin/env ruby
# encoding: UTF-8
require './graph.rb'

es = []
DATA.readlines.each do |ln|
  ns = ln.split.map(&:to_i)
  v = ns.shift
  ns.each{|it| es << [v, it]}
end
=begin
es = [ [0, 4], [2, 3], [2, 6], [3, 4], [4, 5], [7, 8] ]
=end
g = Graph.new(es)
print g
puts
g.depth_first_search(0)
print 'path: '
g.print_path(0, 15)
puts

g.breadth_first_search(0)
print 'path: '
g.print_path(0, 15)
=begin
=end
__END__
0 1 6 8
1 2 3
2 10 11
3 4 12
4 5 13
5 6 9
6 7
7 8 9
8 14
9 15
