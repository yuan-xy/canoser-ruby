
module Canoser
  class Field
    attr_accessor :value

  	def initialize(value)
  		@value = value
  	end
  end

  class Uint8 < Field
    def encode
      [@value].pack("C")
    end

    def self.decode_bytes(bytes)
      new(bytes.unpack("C")[0])
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(1)
      decode_bytes(bytes)
    end
  end

  class Uint16 < Field
    def encode
      [@value].pack("S")
    end

    def self.decode_bytes(bytes)
      new(bytes.unpack("S")[0])
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(2)
      decode_bytes(bytes)
    end
  end

  class Uint32 < Field
    def encode
      [@value].pack("L")
    end

    def self.decode_bytes(bytes)
      new(bytes.unpack("L")[0])
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(4)
      decode_bytes(bytes)
    end
  end

  class Uint64 < Field
    def encode
      [@value].pack("Q")
    end

    def self.decode_bytes(bytes)
      new(bytes.unpack("Q")[0])
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(8)
      decode_bytes(bytes)
    end

    def self.max_value
      2**64-1
    end
  end

  class Bool < Field
    def encode
      @value? "\1" : "\0"
    end

    def self.decode_bytes(bytes)
      return new(true) if bytes == "\1"
      return new(false) if bytes == "\0"
      raise ParseError.new("bool should be 0 or 1.")
    end

    def self.decode(cursor)
      bytes = cursor.read_bytes(1)
      decode_bytes(bytes)
    end
  end

  class Optional
  	def initialize(bool, value)
  	end

  end


end
