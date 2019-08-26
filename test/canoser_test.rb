require "test_helper"

class CanoserTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Canoser::VERSION
  end

  def test_uint8
    x = Canoser::Uint8.new(16)
    assert_equal x.encode, "\x10"
    ret = Canoser::Uint8.decode_bytes("\x10")
    assert_equal ret.value, 16
  end

  def test_uint16
    x = Canoser::Uint16.new(16)
    assert_equal x.encode, "\x10\x00"
    x = Canoser::Uint16.new(257)
    assert_equal x.encode, "\x01\x01"
    ret = Canoser::Uint16.decode_bytes("\x01\x01")
    assert_equal ret.value, 257
  end

  def test_uint32
    x = Canoser::Uint32.new(16)
    assert_equal x.encode, "\x10\x00\x00\x00"
    x = Canoser::Uint32.new(0x12345678)
    assert_equal x.encode, "\x78\x56\x34\x12"
    ret = Canoser::Uint32.decode_bytes("\x78\x56\x34\x12")
    assert_equal ret.value, 0x12345678
  end

  def test_uint64
    x = Canoser::Uint64.new(16)
    assert_equal x.encode, "\x10\x00\x00\x00\x00\x00\x00\x00"
    x = Canoser::Uint64.new(0x1234567811223344)
    assert_equal x.encode, "\x44\x33\x22\x11\x78\x56\x34\x12"    
    ret = Canoser::Uint64.decode_bytes("\x44\x33\x22\x11\x78\x56\x34\x12")
    assert_equal ret.value, 0x1234567811223344
  end

  def test_bool
    x = Canoser::Bool.new(true)
    assert_equal x.encode, "\x1"
    ret = Canoser::Bool.decode_bytes("\x1")
    assert ret.value
    assert_equal Canoser::Bool.new(false).encode, "\0"
    assert_raises Canoser::ParseError do
      Canoser::Bool.decode_bytes("\x2")
    end
  end

  class Address < Canoser::Struct
  	define_field :addr, [Canoser::Uint8], 32
  	define_field :f2, [Canoser::Uint8]
  end

  def test_list_fixed_size
  	addr = (0..31).map{|x| x}
    address = Address.new(addr: addr, f2:[])
    output = address.serialize
    assert_equal output, "\u0000\u0001\u0002\u0003\u0004\u0005\u0006\a\b\t\n\v\f\r\u000E\u000F\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001A\e\u001C\u001D\u001E\u001F\u0000\u0000\u0000\u0000"
    des = Address.new.deserialize(output)
    assert_equal des["addr"], des[:addr]
    (0..31).each{|x| assert_equal address[:addr][x].value, des[:addr][x].value}
    (0..31).each{|x| assert_equal x, des[:addr][x].value}
    assert_equal des[:f2], []
  end

  class BoolVector < Canoser::Struct
    define_field :vec, [Canoser::Bool]
  end

  def test_list_dyn_size
    bools = BoolVector.new(vec: [true,false,true])
    ser = bools.serialize
    assert_equal ser, "\x3\x0\x0\x0\x1\x0\x1"
    vector = BoolVector.new.deserialize(ser)[:vec]
    assert [true,false,true], vector.map{|x| x.value}
  end

  class Map < Canoser::Struct
    define_field :map, {}
  end

#  libra only support [u8] type for both of k and v
#  def test_map_with_string_kv
#    hash = {"k1" => "v1", "k2" => "v2"}
#    ser = Map.new(map: hash).serialize
#    hash2 = Map.new.deserialize(ser)[:map]
#    assert_equal hash, hash2
#  end


  #copy form libra source code
  TEST_VECTOR_1 = "ffffffffffffffff060000006463584d4237640000000000000009000000000102"+
                  "03040506070805050505050505050505050505050505050505050505050505050505"+
                  "05050505630000000103000000010000000103000000161543030000000038150300"+
                  "0000160a05040000001415596903000000c9175a"

  class Addr < Canoser::Struct
    define_field :addr, [Canoser::Uint8], 32
  end

  class Bar < Canoser::Struct
    define_field :a, Canoser::Uint64
    define_field :b, [Canoser::Uint8]
    define_field :c, Addr
    define_field :d, Canoser::Uint32
  end

  class Foo < Canoser::Struct
    define_field :a, Canoser::Uint64
    define_field :b, [Canoser::Uint8]
    define_field :c, Bar
    define_field :d, Canoser::Bool
    define_field :e, {}
  end

  def test_with_libra_case
    addr = Addr.new(addr: (0..31).map{|x| 5})
    bar = Bar.new(
        a: 100,
        b: [0, 1, 2, 3, 4, 5, 6, 7, 8],
        c: addr,
        d: 99,
    )
    map = {}
    map[[0, 56, 21]] = [22, 10, 5]
    map[[1]] = [22, 21, 67]
    map[[20, 21, 89, 105]] = [201, 23, 90]
    foo = Foo.new(
        a: Canoser::Uint64.max_value,
        b: [100, 99, 88, 77, 66, 55],
        c: bar,
        d: true,
        e: map,
    )
    str1 = foo.serialize
    str2 = [TEST_VECTOR_1].pack('H*')
    assert_equal str1, str2 
  end

end
