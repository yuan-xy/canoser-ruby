require "test_helper"

class CanoserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Canoser::VERSION
  end

  class Address < Canoser::Struct
  	define_field :addr, [Canoser::Uint8], 32
  end

  def test_serialize_deserialize
  	addr = (0..31).map{|x| x}
    address = Address.new(addr: addr)
    output = address.serialize
    des = Address.new.deserialize(output)
    assert_equal address["addr"], des["addr"]
  end
end
