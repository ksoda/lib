#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'

class Fixnum
  def to_sym; to_i; end
end
class Graph
  Vertex = Struct.new(:adjacency_cl, :color, :pred, :discovered, :finished, :dist)
  attr_reader :vertices

  def initialize(graph, digraph = nil)
    @vertices = Hash.new{|h, k| h[k] = Vertex.new([]) }

    graph.each do |(u, v)|
      if v.nil? then @vertices[u]; next end
      @vertices[u].adjacency_cl << v
      @vertices[v]
      unless digraph
        @vertices[v].adjacency_cl << u
      end
    end
  end

  def to_s
    str = ''
    @vertices.each_pair do |k, v|
      str += "#{k}->#{v.adjacency_cl} "
    end
    str.chop
  end
  def depth_first_search(s)
    @vertices.each_value do |v|
      v.discovered = v.finished = v.pred = nil
      v.color = :White
    end
    @time = 0
    dfs_visit(s)

    vertices.each_pair do |v_id, v|
      dfs_visit(v_id) if v.color == :White
    end
  end
  def dfs_visit(u_id)
    u = vertices[u_id]
    u.color = :Gray
    u.discovered = @time += 1

    u.adjacency_cl.each do |v_id|
      v = vertices[v_id]
      @acyclic = true if v.color == :Gray
      if v.color == :White
        v.pred = u_id
        dfs_visit(v_id)
      end
    end
    u.color = :Black
    u.finished = @time += 1
  end

  def tsort
    depth_first_search(@vertices.keys.first)
    return false if @acyclic
    @vertices.map{|k, v| [k, v.finished]}.sort_by{|v, k|
      -k}.map(&:first)
  end
  def print_path(s, v)
    if v == s
      print s
    elsif vertices[v].pred.nil?
      print 'no-path'
    else
      print_path(s, vertices[v].pred)
      print ' ', v
    end
  end
  def breadth_first_search(s)
    @vertices.each_value do |v|
      v.pred = nil
      v.dist = Float::MAX
      v.color = :White
    end
    @vertices[s].color = :Gray
    queue = []
    queue << s

    until queue.empty?
      u_id = queue.shift
      u = @vertices[u_id]
      u.adjacency_cl.each do |v_id|
        v = @vertices[v_id]
        if v.color == :White
          v.dist = u.dist + 1
          v.pred = u_id
          v.color = :Gray
          queue << v_id
        end
      end
      u.color = :Black
    end
  end
end
