
module Canoser

  class Struct
  	def self.define_field(name, type, arr_len=nil)
      name = ":"+name.to_sym.to_s
      if type.class == Array
        type =  ArrayT.new(type[0], arr_len)
      elsif type.class == Hash
        type = HashT.new(type.keys[0], type.values[0])
      else
        raise "type #{type} doen't support arr_len param" if arr_len
      end
      str = %Q{
        @@names ||= []
        @@names << #{name}
        @@types ||= []
        @@types << type
        attr_accessor(#{name})
      }
      class_eval str
  	end

  	def initialize(hash={})
  		hash.each do |k,v|
  			idx =  self.class.class_variable_get("@@names").find_index{|x| x==k}
  			raise "#{k} is not a field of #{self}" unless idx
  			type = self.class.class_variable_get("@@types")[idx]
        if type.class == ArrayT
          len = type.fixed_len
          raise "fix-length array #{k}: #{len} != #{v.size}" if len && v.size != len
        end
        instance_variable_set("@#{k}", v)
  		end
  	end

    def ==(other)
      return true if self.equal?(other)
      self.class.class_variable_get("@@names").each_with_index do |name, idx|
        unless instance_variable_get("@#{name}") == other.instance_variable_get("@#{name}")
          return false
        end
      end
      true
    end

    def self.encode(value)
      value.serialize
    end

  	def serialize
      output = ""
  		self.class.class_variable_get("@@names").each_with_index do |name, idx|
  			type = self.class.class_variable_get("@@types")[idx]
        value = instance_variable_get("@#{name}")
        output << type.encode(value)
  		end
      output
  	end

  	def self.deserialize(bytes)
      cursor = Canoser::Cursor.new(bytes)
      ret = decode(cursor)
      raise ParseError.new("bytes not all consumed.") unless cursor.finished?
      ret
  	end

    def self.decode(cursor)
      self.new({}).decode(cursor)
    end

    def decode(cursor)
      self.class.class_variable_get("@@names").each_with_index do |name, idx|
        type = self.class.class_variable_get("@@types")[idx]
        instance_variable_set("@#{name}", type.decode(cursor))
      end
      self
    end

  end

end
