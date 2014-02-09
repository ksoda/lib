#!/usr/bin/env ruby
# encoding: UTF-8

require 'test/unit'
require File.expand_path('../../graph.rb', __FILE__)

class TestGraph < Test::Unit::TestCase

  def setup
    adjs = [[:undershorts, :pants, :shoes], [:socks, :shoes],
              [:watch], [:pants, :shoes, :belt], [:shoes],
              [:shirt, :belt, :tie], [:belt, :jacket], [:tie, :jacket],
              [:jacket]]
    @dg = Graph.new(adjs)
    adjs = [[0, 1, 6, 8], [1, 2, 3], [2, 10, 11], [3, 4, 12],
              [4, 5, 13], [5, 6, 9], [6, 7], [7, 8, 9], [8, 14],
              [9, 15], []]
    @ug = Graph.new(adjs, false)
  end

end
