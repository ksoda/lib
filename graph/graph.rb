#!/usr/bin/env ruby
# encoding: UTF-8
require 'matrix' # for adj matrix
DEBUG = nil

class Fixnum
  def to_key() self; end
end
class String
  def to_key() to_sym; end
end

class Graph
  VertexItem = Struct.new(:color, :pred, :discovered, :finished, :dist)
  attr_reader :adjacencies, :vertices_dict, :directed

  protected
  attr_writer :directed

  public
  def initialize(adjs = [], options = {})
    default = { directed: true, klass: Array, adj_mtx_size: false}
    options = default.merge options

    @adj_matrix_size = options[:adj_mtx_size]
    @directed = options[:directed]
    @vertices_dict = Hash.new{|h, k| h[k] = VertexItem.new }

    unless @adj_matrix_size
      # adj-list
      @adjacencies = Hash.new{|h, k| h[k] = options[:klass].new }

      adjs.each do |adj|
        u = adj.shift
        adj.each {|v| add_edge(u, v)}
      end
    else
      # adj-matrix, index: zero start
      # must not be index gap
      @adjacencies = Array.new(@adj_matrix_size + 1){ [] }
      adjs.each_with_index do |adj, ix|
        u = adj.shift
        adj.each {|v| add_edge(u, v)}
      end
    end

  end # initialize

  class VertexItem
    def inspect() "<#{color}:#{pred}:#{discovered}/#{finished}:#{dist}>"; end
  end

  def to_s
    str = ''
    unless @adj_matrix_size
      each_vertex {|v| str += "#{v}->#{adjacencies[v]} " }
    else
      each_vertex do |v|
        adj = adjacencies[v].each_with_index.
          select{|e,i| e && e.nonzero?}.map{|pair| pair[1]}
        str += "#{v}->#{adj} "
      end
    end
    str.chop
  end

  def make_path(s, v, path = [])
    if v == s
      path << s
    elsif vertices_dict[v].pred.nil?
      raise 'no-path'
    else
      make_path(s, vertices_dict[v].pred, path)
      path << v
    end
  end

  def each_vertex
    unless @adj_matrix_size
      adjacencies.each_key {|v| yield v }
    else
      1.upto(@adj_matrix_size) {|v| yield v}
    end
  end

  def each_edge
    unless @adj_matrix_size
      adjacencies.each_pair do |u, adj|
        adj.each { |v| yield u, v }
      end
    else
      1.upto(@adj_matrix_size) do |u|
        adjacencies[u].each {|v| yield u, v }
      end
    end
  end

  def add_vertex(v) adjacencies[v]; end

  def add_edge(u, v)
    unless @adj_matrix_size
      add_vertex(v)
      adjacencies[u] << v
      adjacencies[v] << u unless @directed
    else
      adjacencies[u][v] = 1
      adjacencies[v][u] = 1 unless @directed
    end
  end
  def delete_edge(u, v)
    unless @adj_matrix_size
      adjacencies[u].delete(v)
      adjacencies[v].delete(u) unless @directed
    else
      adjacencies[u][v] = 0
      adjacencies[v][u] = 0 unless @directed
    end
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
    res.directed = false
    res
  end

  def to_undirected!
    adjacencies.replace to_undirected.adjacencies
    self.directed = false
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

  def init_single_source(s)
    each_vertex do |v|
      v_it = vertices_dict[v]
      v_it.dist = Float::INFINITY
      v_it.pred = nil
    end
    vertices_dict[s].dist = 0
  end
  def relax(u, v)
    v_it, u_it = vertices_dict[v], vertices_dict[u]
    weight = block_given? ? yield(u, v) : 1
    if v_it.dist > u_it.dist + weight
      v_it.dist = u_it.dist + weight
      v_it.pred = u
    end
  end
  def bellman_ford(s, &w)
    init_single_source(s)
  end

end # class Graph
