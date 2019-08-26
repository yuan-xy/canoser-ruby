
module Canoser
  class IntField
    @@pack_map = {8 => "C", 16 => "S", 32 => "L", 64 => "Q"}

    def initialize(int_bits)
      @int_bits = int_bits
    end

    def inspect
      "Uint#{@int_bits}"
    end

    def to_s
      inspect
    end

    def pack_str
      @@pack_map[@int_bits]
    end

    def encode(value)
      [value].pack(pack_str)
    end

    def decode_bytes(bytes)
      bytes.unpack(pack_str)[0]
    end

    def decode(cursor)
      bytes = cursor.read_bytes(@int_bits/8)
      decode_bytes(bytes)
    end

    def max_value
      2**@int_bits - 1
    end
  end

  Uint8 = IntField.new(8)
  Uint16 = IntField.new(16)
  Uint32 = IntField.new(32)
  Uint64 = IntField.new(64)

  class Bool
    def self.encode(value)
      if value
        "\1"
      else
        "\0"
      end
    end

    def self.decode_bytes(bytes)
      return true if bytes == "\1"
      return false if bytes == "\0"
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
