#!/usr/bin/env ruby
# encoding: UTF-8
require 'pp'
require File.expand_path('../graph.rb', __FILE__)

class Network < Graph
  DEBUG = nil
  EdgeItem = Struct.new(:flow, :capacity, :residual)
  class EdgeItem
    def inspect() "#{flow}/#{capacity}(#{residual})" end
  end
  attr_accessor :edges_dict

  def initialize(edges = [])
    super()
    @edges_dict = Hash.new{|h, k| h[k] = EdgeItem.new(0) }
    edges.each do |edge|
      cap = edge.pop
      edges_dict[edge].capacity = cap
      add_edge(*edge)
    end
  end
  def residual_graph # inefficient, update all edges besides aug path edges
    res_g = Graph.new
    bnw = to_undirected
    bnw.directed = true

    bnw.each_edge do |e|
      flow = case @edges_dict[e].capacity
             when nil then 0
             when 0   then -@edges_dict[e.reverse].flow # not member of E
             else @edges_dict[e].flow end
      res_cap = @edges_dict[e].capacity - flow

      edges_dict[e].residual = res_cap
      unless res_cap.zero?
        raise 'negative residual capacity' if res_cap < 0
        res_g.add_edge(*e)
      end
    end
    res_g
  end

  def ford_fulkerson(s = :s, t = :t)
    each_edge {|edge| edges_dict[edge.reverse].capacity = 0}
    begin
      loop do
        res_g = residual_graph
        pp [self, res_g] if DEBUG

        path = res_g.find_path(s, t)
        res_cap_path = path.each_cons(2).map{|e| edges_dict[e].residual}.min
        puts "aug #{path} with #{res_cap_path}" if DEBUG

        path.each_cons(2) do |e|
          sign = edges_dict[e].capacity.zero? ? -1 : 1
          edges_dict[e].flow += sign * res_cap_path
        end
      end
    rescue NoPathError
      edges_dict.each_pair.with_object([]){|(e, v), m|
        m << v.flow if e.first == s}.inject(:+)
    end
  end

  def inspect
    res = ''
    each_edge do |e|
      res << "#{e[0]} #{edges_dict[e.reverse].inspect}" +
        "<->#{edges_dict[e].inspect} #{e[1]}\n"
    end
    res
  end

end # Network
