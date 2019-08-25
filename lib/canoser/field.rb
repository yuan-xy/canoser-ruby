
module Canoser
  class Field
  	def initialize(value)
  		@value = value
  	end

  end

  class Uint8 < Field
    def encode
      [@value].pack("C")
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(1)
      bytes.unpack("C")
    end
  end

  class Uint16 < Field
    def encode
      [@value].pack("S")
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(2)
      bytes.unpack("S")
    end
  end

  class Uint32 < Field
    def encode
      [@value].pack("L")
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(4)
      bytes.unpack("L")
    end
  end

  class Uint64 < Field
    def encode
      [@value].pack("Q")
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(8)
      bytes.unpack("Q")
    end
  end

  class Bool < Field
  end

  class Optional
  	def initialize(bool, value)
  	end

  end


end
