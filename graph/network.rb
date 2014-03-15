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
  def back_edge?(e) edges_dict[e].capacity.zero? ? true : false end
  def flow(e) back_edge?(e) ? -1 * edges_dict[e.reverse].flow :
    edges_dict[e].flow
  end

  def residual_graph # inefficient, update all edges besides aug path edges
    res_g = Graph.new
    bnw = to_undirected # bi-network
    bnw.directed = true

    bnw.each_edge do |e|
      res_cap = edges_dict[e].capacity - flow(e)
      edges_dict[e].residual = res_cap
      unless res_cap.zero?
        raise 'negative residual capacity' if res_cap < 0
        res_g.add_edge(*e)
      end
    end
    res_g
  end

  def flow_conservation?(v, s_t = [:s, :t])
    return true if s_t.include?(v)
    in_flow = edges_dict.select{|e, it| e.last == v }.map{|e, it| it.flow
    }.inject(:+)

    out_flow = edges_dict.select{|e, it| e.first == v }.map{|e, it| it.flow
    }.inject(:+)
    p [in_flow, out_flow] unless in_flow == out_flow
    in_flow == out_flow
  end
  def capacity_constraint?(e)
    back_edge, edge = edges_dict[e.reverse], edges_dict[e]
    not back_edge?(e) and edge.capacity == edge.residual + edge.flow and
      edge.flow == back_edge.residual
  end

  def ford_fulkerson(s = :s, t = :t)
    each_edge {|edge| edges_dict[edge.reverse].capacity = 0}
    begin
      loop do
        res_g = residual_graph
        each_vertex{|v| raise "violation #{v}" unless flow_conservation?(v)}
        each_edge{|e| raise "violation #{e}" unless capacity_constraint?(e)}
        p [self, res_g] if DEBUG

        path = res_g.find_path(s, t)

        res_cap_path = path.each_cons(2).map{|e| edges_dict[e].residual}.min
        puts "aug #{path} with #{res_cap_path}" if DEBUG
        path.each_cons(2) do |e|
          if back_edge?(e) then edges_dict[e.reverse].flow -= res_cap_path
          else edges_dict[e].flow += res_cap_path end
        end
      end
    rescue NoPathError
      edges_dict.each_pair.with_object([]){|(e, v), m|
        m << v.flow if e.first == s}.inject(:+)
    rescue => ex
      puts ex.class
      puts ex.message
      p self if DEBUG
      nil
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
