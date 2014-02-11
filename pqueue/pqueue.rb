class PQueue
  def initialize(elms = nil, &blck)
    # max priority queue as default
    @compare = blck || ->x,y{ -(x <=> y) }
    @queue = [Float::INFINITY * @compare[0, 1]]
    elms.each {|e| push e } if elms
    build
  end
  def heap_size() @queue.size - 1; end
  def top() @queue[1]; end
  def empty?() heap_size.zero?; end

  private
  def build
    (heap_size/2).downto(1){|i| heapify(i)}
  end
  def left(i) 2*i; end
  def right(i) left(i).succ; end
  def parent(i) i/2; end

  def heapify(i)
    que = @queue
    l = left(i); r = right(i)
    highest =  [i, l, r].zip(que.values_at(i, l, r)).reject{|it| it[1].nil?
    }.sort{|x, y| @compare[x[1], y[1]]}.first[0]
    unless highest == i
      que[i], que[highest] = que[highest], que[i]
      heapify(highest)
    end
  end

  public
  def pop
    que = @queue
    case heap_size
    when 1 then que.pop
    when 0 then nil
    else
      res = que[1]
      que[1] = que.pop
      heapify(1)
      res
    end
  end

  def update_with(i, key)
    que = @queue
    cmp = @compare
    return nil if cmp[key, que[i]] > 0
    que[i] = key
    p = parent(i)
    while i > 1 and cmp[que[p], que[i]] > 0
      que[p], que[i] = que[i], que[p]
      i = p; p = parent(i)
    end
  end
  def push(key)
    @queue << -Float::INFINITY * @compare[0, 1] # lt wish to update
    update_with(heap_size, key)
    self
  end
  alias << push

  def each
    while e = pop
      yield e
    end
  end

  def union!(other)
    other.each{|i| push i}
    self
  end
  alias | union!

  def inspect
    "<#{@queue}, #{top || 'nil'}>"
  end
  def to_s
    lv = -1
    depth = Math::log2(heap_size + 1).ceil - 1
    q = @queue.dup; q.shift
    width = Math::log10(q.max).ceil
    @queue.each_with_index do |e, i|
      ws = ' ' * ((width+1) * (2**(depth - lv) - 1))
      e = e.to_s.to_i if e.class == Float and e.infinite?
      printf("%*d #{ws}", width, e)
      if i == 2**(lv + 1) - 1
        lv += 1; puts
      end
    end
    nil
  end
end # class PQueue
