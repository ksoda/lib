#!/usr/bin/env ruby
# encoding: UTF-8
require './graph.rb'
require 'pp'
to_key = (:to_i).to_proc
adjs = DATA.readlines.map{|ln| ln.split.map(&to_key)
}
g = Graph.new(adjs, false)

=begin
p g.tsort
=end
g.breadth_first_search(0)
print 'path: '
g.print_path(0, 15)
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

