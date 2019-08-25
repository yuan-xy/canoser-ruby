module Canoser
  class Cursor
  	def initialize(bytes, offset=0)
  		@bytes = bytes
  		@offset = offset
  	end

  	def read_bytes(size)
  		new_offset = @offset+size
  		raise "" if new_offset > @bytes.size
  		ret = @bytes[@offset..new_offset]
  		@offset = new_offset
  		ret
  	end

  	def finished?
  		@offset == @bytes.size
  	end
  end
end
