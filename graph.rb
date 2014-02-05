#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'

class Graph
  MAX_VERTICES = 100
  Vertex = Struct.new(:neighbours, :color, :pred, :discovered, :finished)
  attr_reader :vertices

  def initialize(graph, digraph = nil)
    @vertices = []
      Hash.new{|h, k| h[k] = Vertex.new }
    @vertex_list = Array.new(MAX_VERTICES) do
      Array.new # > List
    end

    graph.each do |(u, v)|
      @vertex_list[u] << v
      @vertices[u]; @vertices[v]
      @vertex_list[v] << u unless digraph
    end
  end

  def to_s
    str = ''
    @vertex_list.each_with_index do |ns, i|
      next if ns.empty?
      neighbours = ''
      ns.each do |n|
        neighbours += "#{n},"
      end
      str += "#{i}->[#{neighbours.chop}] "
    end
    str.chop
  end
  def depth_first_search(s)
    vertices.each do |k, v|
      v.discovered = v.finished = v.pred = nil
      v.color = :White
    end
    @time = 0
    dfs_visit(s)

    vertices.each do |k, v|
      dfs_visit(k) if v.color == :White
    end
  end
  def dfs_visit(key)
    u = vertices[key]
    u.color = :Gray
    u.discovered = @time += 1

    vertex_list[key].each do |k|
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
