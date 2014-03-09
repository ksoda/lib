#!/usr/bin/env ruby
# encoding: UTF-8

require 'pp'

DEBUG = nil
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

  def add_edge(u, v)
    add_vertex(v)
    unless @adj_matrix
      adjacencies[u] << v
      adjacencies[v] << u unless @directed
    else
      adjacencies[u][v] = 1
      adjacencies[v][u] = 1 unless @directed
    end
  end
  def delete_edge(u, v)
    unless @adj_matrix
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

  def depth_first_search(vtx_ord = nil, t_value = nil, after = nil)
    each_vertex do |v|
      v_it = vertices_dict[v]
      v_it.discovered = v_it.finished = v_it.pred = nil
      v_it.color = :White
    end
    @time = 0

    vtx_ord ||= adjacencies.keys
    dfs_visit(vtx_ord.shift, after)
    vtx_ord.each do |v|
      dfs_visit(v, t_value, after) if vertices_dict[v].color == :White
    end

    each_vertex {|v| p [v, vertices_dict[v]]} if DEBUG
  end

  private
  def dfs_visit(u, t_value = nil, after = nil)

    u_it = vertices_dict[u]
    u_it.color = :Gray
    u_it.discovered = @time += 1

    adjacencies[u].each do |v|
      v_it = vertices_dict[v]
      @cyclic = true if v_it.color == :Gray
      if v_it.color == :White
        v_it.pred = u

        return if t_value and v == t_value
        dfs_visit(v, t_value, after)
      end
    end
    u_it.color = :Black
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


class Network < Graph
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
=begin
  def residual_graph # inefficient, update all edges besides aug path edges
    res_g = Graph.new
    dnw = to_undirected
    dnw.directed = true

    dnw.each_edge do |e|
      flow = case @edges_dict[e].capacity
             when nil then 0
             when 0   then -@edges_dict[e.reverse].flow # not member of E
             else @edges_dict[e].flow end
      res_cap = @edges_dict[e].capacity - flow

      unless res_cap.zero?
        raise 'negative residual capacity' if res_cap < 0
        res_g.add_edge(*e)
        edges_dict[e].residual = res_cap
      end
    end
    res_g
  end
=end

  def ford_fulkerson(s = :s, t = :t)
    each_edge {|edge| edges_dict[edge.reverse].capacity = 0}
    begin
      loop do
        res_g = residual_graph
        #pp [nw, res_g]

        path = res_g.find_path(s, t)
        res_cap_path = path.each_cons(2).map{|e| edges_dict[e].residual}.min
        #puts "aug #{path} with #{res_cap_path}"

        path.each_cons(2) do |e|
          edges_dict[e].flow += res_cap_path
        end
      end
    rescue NoPathError
      edges_dict.each_pair.with_object([]){|(k, v), m|
        m << v.flow if k.first == s}.inject(:+)
    end
  end

  def inspect
    str = ''
    each_vertex do |v|
      adj = adjacencies[v]
      adj = adj.map{|elm| it = @edges_dict[[v, elm]]
        "#{elm}(#{it.flow}/#{it.capacity})" }.join(',')
      str += "#{v}->#{adj} "
    end
    str.chop
  end

end # Network
