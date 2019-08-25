require "test_helper"

class CanoserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Canoser::VERSION
  end

  def test_uint8
    x = Canoser::Uint8.new(16)
    assert_equal x.encode, "\x10"
    ret = Canoser::Uint8.decode(Canoser::Cursor.new("\x10"))
    assert_equal ret.value, 16
  end

  def test_uint16
    x = Canoser::Uint16.new(16)
    assert_equal x.encode, "\x10\x00"
    x = Canoser::Uint16.new(257)
    assert_equal x.encode, "\x01\x01"
    ret = Canoser::Uint16.decode(Canoser::Cursor.new("\x01\x01"))
    assert_equal ret.value, 257
  end

  def test_uint32
    x = Canoser::Uint32.new(16)
    assert_equal x.encode, "\x10\x00\x00\x00"
    x = Canoser::Uint32.new(0x12345678)
    assert_equal x.encode, "\x78\x56\x34\x12"
    ret = Canoser::Uint32.decode(Canoser::Cursor.new("\x78\x56\x34\x12"))
    assert_equal ret.value, 0x12345678
  end

  def test_uint64
    x = Canoser::Uint64.new(16)
    assert_equal x.encode, "\x10\x00\x00\x00\x00\x00\x00\x00"
    x = Canoser::Uint64.new(0x1234567811223344)
    assert_equal x.encode, "\x44\x33\x22\x11\x78\x56\x34\x12"    
    ret = Canoser::Uint64.decode(Canoser::Cursor.new("\x44\x33\x22\x11\x78\x56\x34\x12"))
    assert_equal ret.value, 0x1234567811223344
  end

  class Address < Canoser::Struct
  	define_field :addr, [Canoser::Uint8], 32
  	define_field :f2, [Canoser::Uint8]
  end

  def test_serialize_deserialize
  	addr = (0..31).map{|x| x}
    address = Address.new(addr: addr, f2:[])
    output = address.serialize
    des = Address.new.deserialize(output)
    puts des["addr"]
    assert_equal address["addr"], des["addr"]
  end
end
