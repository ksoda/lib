#!/usr/bin/env ruby
# encoding: UTF-8
require 'pp'

NoPathError = Class.new(RuntimeError)

class Object
  def to_key
    case self
    when Fixnum then self
    when String then to_sym
    else raise 'Not Implemented' end
  end
end

class Graph
  DEBUG = nil
  VertexItem = Struct.new(:color, :pred, :discovered, :finished, :dist)
  attr_reader :adjacencies, :vertices_dict, :directed

  protected
  attr_writer :directed

  public
  def initialize(adjs = [], options = {})
    default = { directed: true, klass: Array, adj_mtxoid: false }
    options = default.merge options

    @adj_matrix = options[:adj_mtxoid]
    @directed = options[:directed]
    @vertices_dict = Hash.new{|h, k| h[k] = VertexItem.new }

    options[:klass] = Array if @adj_matrix
    @adjacencies = Hash.new{|h, k| h[k] = options[:klass].new }

    adjs.each do |adj|
      u = adj.shift
      adj.each {|v| add_edge(u, v)}
    end
  end # initialize

  class VertexItem
    def inspect() "<#{color}:#{pred}:#{discovered}/#{finished}:#{dist}>" end
  end

  def inspect
    str = ''
    each_vertex do |v|
      adj = @adj_matrix ? flg_to_neighbours(adjacencies[v]):
        adjacencies[v]
      str += "#{v}->#{adj} "
    end
    str.chop
  end

  def each_vertex
      adjacencies.each_key {|v| yield v }
  end

  def flg_to_neighbours(adj_row)
    adj_row.each_with_index.select{|e,i| e==1}.map(&:last)
  end
  def each_edge
    adjacencies.each_pair do |u, adj|
      adj = flg_to_neighbours(adj) if @adj_matrix
      adj.each { |v| yield [u, v] }
    end
  end

  def add_vertex(v) adjacencies[v] end

  def add_edge(v1, v2)
    add_e = proc{|u, v|
      add_vertex(v)
      unless @adj_matrix
        adjacencies[u] << v
      else
        adjacencies[u][v] = 1
      end
    }
    add_e[v1, v2]
    add_e[v2, v1] unless @directed
  end
  def delete_edge(v1, v2)
    del_e = proc{|u, v|
      unless @adj_matrix
        adjacencies[u].delete(v)
      else
        adjacencies[u][v] = 0
      end
    }
    del_e[v1, v2]
    del_e[v2, v1] unless @directed
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

  def make_path(s, v, path = [])
    if v == s
      path.unshift s
    elsif vertices_dict[v].pred.nil?
      raise NoPathError
    else
      make_path(s, vertices_dict[v].pred, path.unshift(v))
    end
  end

  def find_path(s, t)
    depth_first_search([s], t)
    make_path(s, t)
  end

  def depth_first_search(vtx_ord = nil, target = nil, after = nil)
    each_vertex do |v|
      v_it = vertices_dict[v]
      v_it.discovered = v_it.finished = v_it.pred = nil
      v_it.color = :white
    end
    @time = 0

    vtx_ord ||= adjacencies.keys
    dfs_visit(vtx_ord.shift, after)
    vtx_ord.each do |v|
      dfs_visit(v, target, after) if vertices_dict[v].color == :white
    end

    each_vertex {|v| p [v, vertices_dict[v]]} if DEBUG
  end

  private
  def dfs_visit(u, target = nil, after = nil)
    u_it = vertices_dict[u]
    u_it.color = :gray
    u_it.discovered = @time += 1

    adjacencies[u].each do |v|
      v_it = vertices_dict[v]
      @cyclic = true if v_it.color == :gray
      if v_it.color == :white
        v_it.pred = u

        return if target and v == target
        dfs_visit(v, target, after)
      end
    end
    u_it.color = :black
    u_it.finished = @time += 1

    after and after[u]
  end

  public
  def top_sort(scc = nil)
    @cyclic = false
    #after = proc{|v| puts "#{v} finished"}
    depth_first_search
    return false if @cyclic and scc.nil?
    vertices_dict.map{|v, v_it| [v, v_it.finished]}.sort_by{|v_it, v|
      -v}.map(&:first) # vertex can be unshifted to result at processed time
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
      v_it.color = :white
    end
    s_it = vertices_dict[s]
    s_it.color = :gray
    s_it.dist = 0
    queue = []
    queue << s

    until queue.empty?
      u = queue.shift
      u_it = vertices_dict[u]
      adjacencies[u].each do |v|
        v_it = vertices_dict[v]
        if v_it.color == :white
          v_it.dist = u_it.dist + 1
          v_it.pred = u
          v_it.color = :gray
          queue << v
        end
      end
      u_it.color = :black
    end
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
  end

end # class Graph
