import Config

config :nin_db,
   ecto_repos: [NinDB.Repo]

config :nin_db, NinDB.Repo,
  database: "nindb",
  hostname: "localhost"
