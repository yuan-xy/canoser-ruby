require 'byebug'

module Canoser

  refine Array do
    def encode(type=Uint8)
      output = ""
      output << Uint32.new(self.size).encode
      self.each{|x| output << type.new(x).encode}
      output   
    end
  end

  refine Array.singleton_class do
    def decode(cursor, type=Uint8)
      arr = []
      len = Uint32.decode(cursor).value
      len.times do
        arr << type.decode(cursor).value
      end
      arr 
    end
  end

  refine Hash do
    def encode
      output = ""
      output << Uint32.new(self.size).encode
      sorted_map = {}
      self.each do |k, v|
        sorted_map[k.encode] = v.encode
      end
      sorted_map.keys.sort.each do |k|
        output << k
        output << sorted_map[k]
      end
      output
    end
  end

  refine Hash.singleton_class do
    def decode(cursor)
      hash = {}
      len = Uint32.decode(cursor).value
      len.times do
        ksize = Uint32.decode(cursor).value
        k = cursor.read_bytes(ksize)
        vsize = Uint32.decode(cursor).value
        v = cursor.read_bytes(vsize)
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
          raise "#{k}-#{type} #{len} != #{v.size}" if len && v.size != len
          inner_type = type[0]
          vv = v.map{|x| inner_type.new(x)}
          @values[k] = vv
        elsif type.class == Hash || type.ancestors.include?(Canoser::Struct)
          @values[k] = v
        else
          @values[k] = type.new(v)
        end
  		end
  	end

    def [](name)
      @values[name.to_sym]
    end

  	def serialize
      output = ""
  		self.class.class_variable_get("@@names").each_with_index do |name, idx|
  			type = self.class.class_variable_get("@@types")[idx]
        value = @values[name]
        if type.class == Array
          len = self.class.class_variable_get("@@arr_lens")[name]
          output << Uint32.new(value.size).encode unless len
          value.each{|x| output << x.encode}
        elsif type.class == Hash
          output << value.encode
        elsif type.ancestors.include?(Canoser::Struct)
          output << value.serialize
        else
          output << value.encode
        end
  		end
      output
  	end

  	def deserialize(bytes)
      cursor = Canoser::Cursor.new(bytes)
  		self.class.class_variable_get("@@names").each_with_index do |name, idx|
  			type = self.class.class_variable_get("@@types")[idx]
        if type.class == Array
          len = self.class.class_variable_get("@@arr_lens")[name]
          unless len #dynamic sized array
            len = Uint32.decode(cursor).value
          end
          arr = []
          inner_type = type[0]
          len.times{ arr.push(inner_type.decode(cursor))}
          @values[name] = arr
        elsif type.class == Hash
          @values[name] = Hash.decode(cursor)
        else
          @values[name] = type.decode(cursor)
        end
  		end
      raise ParseError.new("bytes not all consumed.") unless cursor.finished?
      self
  	end

  end

end
