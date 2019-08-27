# Canoser


Canoser是facebook推出的Libra网络中使用的规范序列化(canonical serialization)协议的第三方ruby实现框架。

规范序列化可确保内存里的数据结构在序列化的时候保证字节一致性。它适用于双方想要有效比较他们独立维护的数据结构。在共识协议中，独立验证者需要就他们独立计算的状态达成一致。共识双方比较的是序列化数据的加密散列。要实现这一点，在计算时，相同数据结构的序列化必须相同。而独立验证器可能由不同的语言编写，有不同的实现代码，但是都遵循同一个规范。


## 安装

添加下列行到你的项目的Gemfile文件:

```ruby
gem 'canoser'
```

然后执行:

    $ bundle

或者直接通过命令行安装:

    $ gem install canoser

## 使用

首先用Canoser定义一个数据结构，也就是写一个类继承自"Canoser::Struct"，然后通过"define_field"方法来定义该结构所拥有的字段。该结构自然就拥有了序列化和反序列化的能力。例如下面的AccountResource定义了一个Libra代码中的同名数据结构：
```ruby
  #ruby代码，利用canoser定义数据结构
  class AccountResource < Canoser::Struct
  	define_field :authentication_key, [Canoser::Uint8]
  	define_field :balance, Canoser::Uint64
  	define_field :delegated_withdrawal_capability, Canoser::Bool
  	define_field :received_events_count, Canoser::Uint64
  	define_field :sent_events_count, Canoser::Uint64
  	define_field :sequence_number, Canoser::Uint64
  end
```

下面是Libra中定义该数据结构以及序列化的代码：
```rust
// Libra中的rust语言代码
// 定义数据结构
pub struct AccountResource {
    balance: u64,
    sequence_number: u64,
    authentication_key: ByteArray,
    sent_events_count: u64,
    received_events_count: u64,
    delegated_withdrawal_capability: bool,
}
// 实现序列化
impl CanonicalSerialize for AccountResource {
    fn serialize(&self, serializer: &mut impl CanonicalSerializer) -> Result<()> {
        serializer
            .encode_struct(&self.authentication_key)?
            .encode_u64(self.balance)?
            .encode_bool(self.delegated_withdrawal_capability)?
            .encode_u64(self.received_events_count)?
            .encode_u64(self.sent_events_count)?
            .encode_u64(self.sequence_number)?;
        Ok(())
    }
}
```
在Libra使用的rust语言中，需要手动写代码实现数据结构的序列化/反序列化，而且数据结构中的字段顺序和序列化时的顺序不一定一致。
在Canoser中，定义好数据结构后，不需要写序列化和反序列化的代码。注意，Canoser中的数据结构顺序要按照Libra中序列化的顺序来定义。

### 支持的数据类型

字段支持的类型有：

| 字段类型 | 可选子类型 | 说明 |
| ------ | ------ | ------ |
| Canoser::Uint8 |  | 无符号8位整数 |
| Canoser::Uint16 |  | 无符号16位整数 |
| Canoser::Uint32 |  | 无符号32位整数 |
| Canoser::Uint64 |  | 无符号64位整数 |
| Canoser::Bool |  | 布尔类型 |
| Canoser::Str |  | 字符串 |
| [] | 支持 | 数组类型 |
| {} | 支持 |  Map类型 |
| A Canoser::Struct Name |  | 嵌套的另外一个结构（不能循环引用） |

### 关于数组类型
数组里的数据，如果没有定义类型，那么缺省是Uint8。下面的两个定义等价：
```ruby
  class Arr1 < Canoser::Struct
    define_field :addr, []
  end
  class Arr2 < Canoser::Struct
    define_field :addr, [Canoser::Uint8]
  end  
```  
数组还可以定义长度，表示定长数据。比如Libra中的地址是256位，也就是32个字节，所以可以如下定义：
```ruby
  class Address < Canoser::Struct
    define_field :addr, [Canoser::Uint8], 32
  end  
```  
定长数据在序列化的时候，不写入长度信息。

### 关于Map类型
Map里的数据，如果没有定义类型，那么缺省是字节数组。下面的两个定义等价：
```ruby
  class Map1 < Canoser::Struct
    define_field :addr, {}
  end
  class Map2 < Canoser::Struct
    define_field :addr, {[Canoser::Uint8] => [Canoser::Uint8]}
  end  
```  

### 结构嵌套
下面是一个复杂的例子，包含三个数据结构：
```ruby
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
```
这个例子参考自libra中canonical serialization的测试代码。

### 序列化和反序列化
在定义好Canoser::Struct后，不需要自己实现序列化和反序列化代码，直接调用基类的默认实现即可。以AccountResource结构为例：
```ruby
#序列化
obj = AccountResource.new(authentication_key:[...],...)
bytes = obj.serialize
#反序列化
obj = AccountResource.deserialize(bytes)
```

