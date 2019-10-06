
module Canoser
  class IntField
    @@pack_map = {8 => "C", 16 => "S", 32 => "L", 64 => "Q"}

    def initialize(int_bits, signed=false)
      @int_bits = int_bits
      @signed = signed
    end

    def inspect
      if @signed
        "Int#{@int_bits}"
      else
        "Uint#{@int_bits}"
      end
    end

    def to_s
      inspect
    end

    def pack_str
      str = @@pack_map[@int_bits]
      str = str.downcase if @signed
      str
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
      if @signed
        2**(@int_bits-1) - 1
      else
        2**@int_bits - 1
      end
    end
  end

  Uint8 = IntField.new(8)
  Uint16 = IntField.new(16)
  Uint32 = IntField.new(32)
  Uint64 = IntField.new(64)

  Int8 = IntField.new(8, true)
  Int16 = IntField.new(16, true)
  Int32 = IntField.new(32, true)
  Int64 = IntField.new(64, true)

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


  class Str
    def self.encode(value)
      output = ""
      bytes = value.bytes
      output << Uint32.encode(bytes.size)
      bytes.each{|x| output << Canoser::Uint8.encode(x)}
      output
    end

    def self.decode(cursor)
      str = ""
      len = Uint32.decode(cursor)
      len.times do
        str << Uint8.decode(cursor)
      end
      str
    end
  end


  class ArrayT
    attr_accessor :type, :fixed_len

    def initialize(type=Uint8, fixed_len=nil)
      @type = type
      @fixed_len = fixed_len
    end

    def encode(arr)
      output = ""
      output << Uint32.encode(arr.size)
      arr.each{|x| output << @type.encode(x)}
      output
    end

    def decode(cursor)
      arr = []
      len = Uint32.decode(cursor)
      if @fixed_len && len != @fixed_len
        raise ParseError.new("fix-len:#{@fixed_len} != #{len}")
      end
      len.times do
        arr << @type.decode(cursor)
      end
      arr
    end

    def ==(other)
      return self.type == other.type && self.fixed_len == other.fixed_len
    end

  end

  DEFAULT_KV = ArrayT.new(Uint8)

  class HashT
    attr_accessor :ktype, :vtype

    def initialize(ktype=DEFAULT_KV, vtype=DEFAULT_KV)
      @ktype = ktype || DEFAULT_KV
      @vtype = vtype || DEFAULT_KV
    end

    def encode(hash)
      output = ""
      output << Uint32.encode(hash.size)
      sorted_map = {}
      hash.each do |k, v|
        sorted_map[ktype.encode(k)] = vtype.encode(v)
      end
      sorted_map.keys.sort.each do |k|
        output << k
        output << sorted_map[k]
      end
      output
    end

    def decode(cursor)
      hash = {}
      len = Uint32.decode(cursor)
      len.times do
        k = ktype.decode(cursor)
        v = vtype.decode(cursor)
        hash[k] = v
      end
      hash
    end

    def ==(other)
      return self.ktype == other.ktype && self.vtype == other.vtype
    end

  end


  class Optional
  	def initialize(bool, value)
  	end

  end


end
