require 'byebug'

module Canoser
  class Struct
  	def self.define_field(name, type, arr_len=nil)
      name = ":"+name.to_sym.to_s
      arr_len_to_s = arr_len
      arr_len_to_s = "nil" if arr_len==nil      
      str = %Q{
      @@names ||= []
      @@names << #{name}
      @@types ||= []
      @@types << #{type}
      @@arr_lens ||= {}
      raise "type #{type} doen't support arr_len param" unless #{type}.class==Array
      @@arr_lens[#{name}] = #{arr_len_to_s} if #{arr_len_to_s} != nil
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
        else
          @values[name] = type.decode(cursor)
        end
  		end
      raise ParseError.new("bytes not all consumed.") unless cursor.finished?
      self
  	end

  end
end
