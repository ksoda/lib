#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'

class Graph
  #MAX_VERTICES = 100
  Vertex = Struct.new(:adjacency_cl, :color, :pred, :discovered, :finished)
  attr_reader :vertices

  def initialize(graph, digraph = nil)
    @vertices = Array.new

    graph.each do |(u, v)|
      @vertices[u] = Vertex.new([]) if @vertices[u].nil?
      @vertices[u].adjacency_cl << v
      unless digraph
        @vertices[v] = Vertex.new([]) if @vertices[v].nil?
        @vertices[v].adjacency_cl << u
      end
    end
  end

  def to_s
    str = ''
    @vertices.each_with_index do |v, k|
      str += "#{k}->#{v.adjacency_cl} "
    end
    str.chop
  end
  def depth_first_search(s)
    @vertices.each do |v|
      v.discovered = v.finished = v.pred = nil
      v.color = :White
    end
    @time = 0
    dfs_visit(s)

    vertices.each_with_index do |v, k|
      dfs_visit(k) if v.color == :White
    end
  end
  def dfs_visit(key)
    u = vertices[key]
    u.color = :Gray
    u.discovered = @time += 1

    u.adjacency_cl.each do |k|
      v = vertices[k]
      if v.color == :White
        v.pred = key
        dfs_visit(k)
      end
    end
    u.color = :Black
    u.finished = @time += 1
  end
  def print_path(s, v)
    if v == s
      print s
    elsif vertices[v].pred == nil
      print 'no-path'
    else
      print_path(s, vertices[v].pred)
      print ' ', v
    end
  end
end
