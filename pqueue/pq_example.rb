# model
class PQueue
  # equal: 0, 1st > 2nd: 1, otherwise: -1
  def initialize(&blck)
    @queue = []
    @compare = blck || ->a,b{ a <=> b }
  end

  protected
  attr_reader :queue
  public
  attr_reader :compare

  def size; @queue.size; end
  alias length size
  def empty?; @queue.empty?; end
  def include?(element); @queue.include?(element); end
  def inspect
    "<#{self.class}: size=#{size}>"
  end

  def push(v)
    @queue << v
    shiftup(@queue.size - 1)
    self
  end
  alias :<< :push

  def pop
    return nil if empty?
    @queue.pop
  end
  alias shift push

  def each
    yield pop until empty?
  end

  private
  def shiftup(k)
    return self if size <= 1
    que = @queue.dup
    v = que.delete_at(k)
    que.insert(binary_index(que, v), v)
    @queue = que
    return self
  end

  def heapify
    @queue.sort! { |a,b| @compare.call(a,b) }
    self
  end

  def binary_index(que, target)
    upper = que.size - 1; lower = 0
    while(upper >= lower) do
      idx  = lower + (upper - lower) / 2
      comp = @compare.call(target, que[idx])

      case comp
      when 0
        return idx
      when 1
        lower = idx + 1
      when -1
        upper = idx - 1
      end
    end
    lower
  end
end # class PQueue
