type Clickhouse_Keeper::Raft_config = Hash[String, Struct[{
      id => Integer,
      address => String,
      port => Integer,
      cluster => String,
  }]
]
