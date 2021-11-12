import Config

config :nin_db,
   ecto_repos: [NinDB.Repo]

config :nin_db, NinDB.Repo,
  database: "nindb",
  hostname: "localhost"

config :nin_db, NinDB.Vault,
  ciphers: [
   default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1",
      key: Base.decode64!("goQI42SEuU17EvCwQ9jdlKxDeSecXF7s02wnNwkwuEI="),
      iv_length: 12
    }
  ]
