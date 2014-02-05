#!/usr/bin/env ruby
# encoding: UTF-8

maze = DATA.readlines.map { |line| line.chomp.split(//) }
nodes = {}
maze.each.with_index do |line, y|
  line.each.with_index do |data, x|
    next if data == '*'
    id = data.match(/\w/) ? $& : "#{y}_#{x}"
    edges =
      [[-1, 0], [1, 0], [0, -1], [0, 1]].inject([]) do |mem, (_y, _x)|
        _x += x; _y += y
        case maze[_y][_x]
        when /\w/ then mem << $&
        when /\s/ then mem << "#{_y}_#{_x}"
        else mem
        end
      end.map { |nid| [1, nid] }
    nodes[id] = edges
  end
end
g = Graph.new(nodes)
__END__
***************************
*S* *                    *
* * *  *  *************  *
* *   *    ************  *
*    *                   *
*************** ***********
*                        *
*** ***********************
*      *              G  *
*  *      *********** *  *
*    *        ******* *  *
*       *                *
***************************
