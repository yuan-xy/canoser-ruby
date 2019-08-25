require 'byebug'

module Canoser
  class Struct
  	def self.define_field(name, type, arr_len=nil)
  		@@names ||= []
  		@@names << name
  		@@types ||= []
  		@@types << type
  		@@arr_lens ||= {}
      raise "type #{type} doen't support arr_len param" unless type.class==Array
  		@@arr_lens[type] = arr_len if arr_len
  	end

  	def initialize(hash={})
      @values = {}
  		hash.each do |k,v|
  			idx =  @@names.find_index{|x| x==k}
  			raise "#{k} is not a field of #{self}" unless idx
  			type = @@types[idx]
        if type.class == Array
          len = @@arr_lens[type]
          raise "#{len} != #{v.size}" if len && v.size != len
          inner_type = type[0]
          vv = v.map{|x| inner_type.new(x)}
          @values[k] = vv
        else
          @values[k] = type.new(v)
        end
  		end
  	end

    def [](name)
      @values[name]
    end

  	def serialize
      output = ""
  		@@names.each_with_index do |name, idx|
  			type = @@types[idx]
        value = @values[name]
        if type.class == Array
          len = @@arr_lens[type]
          output << value.size unless len
          value.each{|x| output << x.encode}
        else
          output << value.encode
        end
  		end
      output
  	end

  	def deserialize(bytes)
      cursor = Canoser::Cursor.new(bytes)
  		@@names.each_with_index do |name, idx|
  			type = @@types[idx]
        if type.class == Array
          len = @@arr_lens[type]
          unless len
            len = decode_len(bytes)
          end
          arr = []
          inner_type = type[0]
          len.times{ arr.push(inner_type.decode(cursor))}
          @values[name] = arr
        else
          @values[name] = type.decode(cursor)
        end
  		end
      self
  	end

  end
end
