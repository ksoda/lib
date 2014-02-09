#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'
#require 'matrix' # for adj matrix

class Fixnum
  def to_key; self; end
end
class String
  def to_key; to_sym; end
end
class Graph
  VertexItem = Struct.new(:color, :pred, :discovered, :finished, :dist)
  attr_reader :adjacencies, :vertices_dict

  def initialize(adjs = {}, directed = true, klass = Array)
    @vertices_dict = Hash.new{|h, k| h[k] = VertexItem.new }
    @adjacencies = Hash.new{|h, k| h[k] = klass.new }

    adjs.each do |adj|
      v = adj.shift
      @adjacencies[v] = adj
    end
    unless directed
      to_undirected!
    end
  end

  def each_vertex
    @adjacencies.each_key {|v| yield v }
  end

  def each_edge
    @adjacencies.each_pair do |u, adj|
      adj.each { |v| yield u, v }
    end
  end

  def add_vertex(v)
    @adjacencies[v]
  end

  def add_edge(u, v)
    add_vertex(v)
    @adjacencies[u] << v
  end

  def transpose
    g = self.class.new
    each_edge { |u,v| g.add_edge(v, u) }
    g
  end

  def to_undirected
    res = transpose
    res.adjacencies.update(adjacencies){|key, self_v, other_v|
      self_v | other_v }
    res
  end
  def to_undirected!
    @adjacencies.replace to_undirected.adjacencies
    self
  end

  def to_s
    str = ''
    each_vertex do |v|
      str += "#{v.to_key}->#{@adjacencies[v]} "
    end
    str.chop
  end

  def print_path(s, v)
    if v == s
      print s
    elsif @vertices_dict[v].pred.nil?
      print 'no-path'
    else
      print_path(s, @vertices_dict[v].pred)
      print ' ', v
    end
  end

  def depth_first_search(s)
    each_vertex do |v|
      v_it = @vertices_dict[v]
      v_it.discovered = v_it.finished = v_it.pred = nil
      v_it.color = :White
    end
    @time = 0
    dfs_visit(s)

    each_vertex do |v|
      dfs_visit(v) if @vertices_dict[v].color == :White
    end
  end

  private
  def dfs_visit(u, before = nil, after = nil)
    before && before[]

    u_it = @vertices_dict[u]
    u_it.color = :Gray
    u_it.discovered = @time += 1

    @adjacencies[u].each do |v|
      v_it = @vertices_dict[v]
      @acyclic = true if v_it.color == :Gray
      if v_it.color == :White
        v_it.pred = u
        dfs_visit(v)
      end
    end
    u_it.color = :Black
    u_it.finished = @time += 1
    after && after[]
  end

  public
  def tsort(s = @adjacencies.keys.first)
    depth_first_search(s)
    return false if @acyclic
    @vertices_dict.map{|v, v_it| [v, v_it.finished]}.sort_by{|v_it, v|
      -v}.map(&:first) # 黒になったときlistの頭に加えたほうがよい
  end

  def breadth_first_search(s)
    each_vertex do |v|
      v_it = @vertices_dict[v]
      v_it.pred = nil
      v_it.dist = Float::MAX
      v_it.color = :White
    end
    @vertices_dict[s].color = :Gray
    queue = []
    queue << s

    until queue.empty?
      u = queue.shift
      u_it = @vertices_dict[u]
      @adjacencies[u].each do |v|
        v_it = @vertices_dict[v]
        if v_it.color == :White
          v_it.dist = u_it.dist + 1
          v_it.pred = u
          v_it.color = :Gray
          queue << v
        end
      end
      u_it.color = :Black
    end
  end
end # class Graph
