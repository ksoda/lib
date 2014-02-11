#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'
#require 'matrix' # for adj matrix
DEBUG = nil

class Fixnum
  def to_key() self; end
end
class String
  def to_key() to_sym; end
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

  class VertexItem
    def inspect() "<#{color}:#{pred}:#{discovered}/#{finished}:#{dist}>"; end
  end

  def to_s
    str = ''
    each_vertex do |v|
      str += "#{v}->#{adjacencies[v]} "
    end
    str.chop
  end

  def print_path(s, v)
    if v == s
      print s
    elsif vertices_dict[v].pred.nil?
      print 'no-path'
    else
      print_path(s, vertices_dict[v].pred)
      print ' ', v
    end
  end


  def each_vertex
    adjacencies.each_key {|v| yield v }
  end

  def each_edge
    adjacencies.each_pair do |u, adj|
      adj.each { |v| yield u, v }
    end
  end

  def add_vertex(v) adjacencies[v]; end

  def add_edge(u, v)
    add_vertex(v)
    adjacencies[u] << v
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
    adjacencies.replace to_undirected.adjacencies
    self
  end


  def depth_first_search(vtx_ord = nil, after = nil)
    each_vertex do |v|
      v_it = vertices_dict[v]
      v_it.discovered = v_it.finished = v_it.pred = nil
      v_it.color = :White
    end
    @time = 0
    vtx_ord ||= adjacencies.keys
    dfs_visit(vtx_ord.shift, after)
    vtx_ord.each do |v|
      dfs_visit(v, after) if vertices_dict[v].color == :White
    end

    if DEBUG
      each_vertex do|v|
        p [v, vertices_dict[v]]
      end
    end
  end

  private
  def dfs_visit(u, after = nil)

    u_it = vertices_dict[u]
    u_it.color = :Gray
    u_it.discovered = @time += 1

    adjacencies[u].each do |v|
      v_it = vertices_dict[v]
      @cyclic = true if v_it.color == :Gray
      if v_it.color == :White
        v_it.pred = u
        dfs_visit(v, after)
      end
    end
    u_it.color = :Black
    u_it.finished = @time += 1

    after && after[u]
  end

  public
  def top_sort(scc = nil)
    @cyclic = false
    #after = proc{|v| puts "#{v} finished"}
    depth_first_search
    return false if @cyclic and scc.nil?
    vertices_dict.map{|v, v_it| [v, v_it.finished]}.sort_by{|v_it, v|
      -v}.map(&:first) # 黒になったときlistの頭に加えたほうがよい
  end

  def s_connnected_component
    v_ord = top_sort(true)
    tg = transpose
    tg.depth_first_search(v_ord)
    tg.vertices_dict.select{|v, it| it.pred.nil?}.keys
  end


  def breadth_first_search(s = adjacencies.keys.first)
    each_vertex do |v|
      v_it = vertices_dict[v]
      v_it.pred = nil
      v_it.dist = Float::INFINITY
      v_it.color = :White
    end
    s_it = vertices_dict[s]
    s_it.color = :Gray
    s_it.dist = 0
    queue = []
    queue << s

    until queue.empty?
      u = queue.shift
      u_it = vertices_dict[u]
      adjacencies[u].each do |v|
        v_it = vertices_dict[v]
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

  # Incomplete
  def bipartite
    # unless odd cycle exist
    breadth_first_search
    vertices_dict.partition{|v, v_it| v_it.dist.even?}.
      map{|bl| bl.map(&:first)}
  end

end # class Graph
