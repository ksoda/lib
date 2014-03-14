#!/usr/bin/env ruby
# encoding: UTF-8
require 'test/unit'
require File.expand_path('../../network.rb', __FILE__)

class TestNetwork < Test::Unit::TestCase

  def setup
    edges = [[:s, :o, 3], [:s, :p, 3], [:o, :p, 2], [:o, :q, 3], [:p, :r, 2],
             [:r, :t, 3], [:q, :r, 4], [:q, :t, 2]]
    @nw = Network.new(edges)

    edges = [[:s, :v1, 16], [:s, :v2, 13], [:v1, :v3, 12], [:v2, :v1, 4],
             [:v2, :v4, 14], [:v3, :v2, 9], [:v3, :t, 20], [:v4, :v3, 7],
             [:v4, :t, 4]]
    @nw2 = Network.new(edges)
  end

  def test_sth
    assert_equal(@nw.ford_fulkerson, 5)
    assert_equal(@nw2.ford_fulkerson, 23)
  end

end
