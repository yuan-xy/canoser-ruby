require 'byebug'

module Canoser

  refine Array do
    def encode(arr, len=nil, type=Uint8)
      output = ""
      output << Uint32.encode(arr.size) unless len
      arr.each{|x| output << type.encode(x)}
      output
    end

    def decode(cursor, len=nil, type=Uint8)
      arr = []
      len = Uint32.decode(cursor) unless len
      len.times do
        arr << type.decode(cursor)
      end
      arr 
    end
  end

  refine Hash do
    def encode(hash, ktype=[Uint8], vtype=[Uint8])
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

    def decode(cursor, ktype=[Uint8], vtype=[Uint8])
      hash = {}
      len = Uint32.decode(cursor)
      len.times do
        k = ktype.decode(cursor)
        v = vtype.decode(cursor)
        hash[k] = v
      end
      hash
    end
  end

  using Canoser

  class Struct
  	def self.define_field(name, type, arr_len=nil)
      name = ":"+name.to_sym.to_s
      arr_len_to_s = arr_len.to_s
      arr_len_to_s = "nil" if arr_len==nil      
      str = %Q{
      @@names ||= []
      @@names << #{name}
      @@types ||= []
      @@types << #{type}
      @@arr_lens ||= {}
      if #{arr_len_to_s} != nil
        if #{type}.class==Array
          @@arr_lens[#{name}] = #{arr_len_to_s}
        else
          raise "type #{type} doen't support arr_len param"
        end
      end
      }
      class_eval str
  	end

  	def initialize(hash={})
      @values = {}
  		hash.each do |k,v|
  			idx =  self.class.class_variable_get("@@names").find_index{|x| x==k}
  			raise "#{k} is not a field of #{self}" unless idx
  			type = self.class.class_variable_get("@@types")[idx]
        if type.class == Array
          len = self.class.class_variable_get("@@arr_lens")[k]
          raise "fix-length array #{k}: #{len} != #{v.size}" if len && v.size != len
        end
        @values[k] = v
  		end
  	end

    def [](name)
      @values[name.to_sym]
    end

    def self.encode(value)
      value.serialize
    end

  	def serialize
      output = ""
  		self.class.class_variable_get("@@names").each_with_index do |name, idx|
  			type = self.class.class_variable_get("@@types")[idx]
        value = @values[name]
        if type.class == Array
          len = self.class.class_variable_get("@@arr_lens")[name]
          output << type.encode(value, len, type[0])
        else
          output << type.encode(value)
        end
  		end
      output
  	end

  	def deserialize(bytes)
      cursor = Canoser::Cursor.new(bytes)
      decode(cursor)
  	end

    def self.decode(cursor)
      self.new({}).decode(cursor)
    end

    def decode(cursor)
      self.class.class_variable_get("@@names").each_with_index do |name, idx|
        type = self.class.class_variable_get("@@types")[idx]
        len = self.class.class_variable_get("@@arr_lens")[name]
        if len
          @values[name] = type.decode(cursor, len)
        else
          @values[name] = type.decode(cursor)
        end
      end
      #raise ParseError.new("bytes not all consumed.") unless cursor.finished?
      self
    end

  end

end
