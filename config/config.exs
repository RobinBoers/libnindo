import Config

config :nindb,
  ecto_repos: [NinDB.Repo]

config :nindb, NinDB.Repo,
  database: "nindb",
  hostname: "localhost"

config :nindb, NinDB.Vault,
  ciphers: [
    default: {
      Cloak.Ciphers.AES.GCM,
      tag: "AES.GCM.V1",
      key: Base.decode64!("goQI42SEuU17EvCwQ9jdlKxDeSecXF7s02wnNwkwuEI="),
      iv_length: 12
    }
  ]

config :nindo,
  base_url: "nindo.geheimesite.nl",
  invidious_instance: "https://yewtu.be"
