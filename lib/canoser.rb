# What is canonical serialization?
#
# Canonical serialization guarantees byte consistency when serializing an in-memory
# data structure. It is useful for situations where two parties want to efficiently compare
# data structures they independently maintain. It happens in consensus where
# independent validators need to agree on the state they independently compute. A cryptographic
# hash of the serialized data structure is what ultimately gets compared. In order for
# this to work, the serialization of the same data structures must be identical when computed
# by independent validators potentially running different implementations
# of the same spec in different languages.
#
# One design
# goal of this serialization format is to optimize for simplicity. It is not designed to be
# another full-fledged network serialization as Protobuf or Thrift. It is designed
# for doing only one thing right, which is to deterministically generate consistent bytes
# from a data structure.
#
# An extremely simple implementation of CanonicalSerializer is also provided, the encoding
# rules are:
# (All unsigned integers are encoded in little-endian representation unless specified otherwise)
#
# 1. The encoding of an unsigned 64-bit integer is defined as its little-endian representation
#    in 8 bytes
#
# 2. The encoding of an item (byte array) is defined as:
#    [length in bytes, represented as 4-byte integer] || [item in bytes]
#
#
# 3. The encoding of a list of items is defined as: (This is not implemented yet because
#    there is no known struct that needs it yet, but can be added later easily)
#    [No. of items in the list, represented as 4-byte integer] || encoding(item_0) || ....
#
# 4. The encoding of an ordered map where the keys are ordered by lexicographic order.
#    Currently, we only support key and value of type Vec<u8>. The encoding is defined as:
#    [No. of key value pairs in the map, represented as 4-byte integer] || encode(key1) ||
#    encode(value1) || encode(key2) || encode(value2)...
#    where the pairs are appended following the lexicographic order of the key
#
require "canoser/version"
require "canoser/cursor"
require "canoser/field"
require "canoser/struct"

module Canoser
	class ParseError < StandardError; end
end
