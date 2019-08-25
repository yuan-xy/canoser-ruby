module Canoser
  class Cursor
  	def initialize(bytes, offset=0)
  		@bytes = bytes
  		@offset = offset
  	end

  	def read_bytes(size)
  		raise ParseError.new("#{@offset+size} exceed bytes size:#{@bytes.size}") if @offset+size > @bytes.size
  		ret = @bytes[@offset, size]
  		@offset += size
  		ret
  	end

    def peek_bytes(size)
      raise ParseError.new("#{@offset+size} exceed bytes size:#{@bytes.size}") if @offset+size > @bytes.size
      @bytes[@offset, size]
    end    

  	def finished?
  		@offset == @bytes.size
  	end
  end
end
