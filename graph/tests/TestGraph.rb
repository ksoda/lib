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
    @dag = Graph.new(adjs)

    adjs = [[0, 1, 6, 8], [1, 2, 3], [2, 10, 11], [3, 4, 12],
              [4, 5, 13], [5, 6, 9], [6, 7], [7, 8, 9], [8, 14],
              [9, 15], []]
    @ug = Graph.new(adjs, false)

    adjs = [[:a, :b, :c], [:b, :a], [:c, :d], [:d, :c]]
    @scc1 = Graph.new(adjs)
    @scc1_cr_ss = [[:a, :b], [:c, :d]]

    adjs = [[:a, :b], [:b, :c, :e, :f], [:c, :d, :g], [:d, :c, :h],
            [:e, :a, :f], [:f, :g], [:g, :f, :h], [:h, :h]]
    @scc2 = Graph.new(adjs)
    @scc2_cr_ss = [[:a, :b, :e], [:c, :d], [:f, :g], [:h]]

    adjs = [[:a, :x, :y], [:b, :x, :y], [:c, :x, :z], [:d, :y, :z]]
    @bg = Graph.new(adjs, false)

  end
  def test_scc
    scc = @scc1.s_connnected_component
    assert_equal @scc1_cr_ss.reject{|cs| cs & scc}, []
  end

end
