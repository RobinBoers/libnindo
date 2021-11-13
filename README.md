# Nindo

A 90% feature complete rewrite of [Nindo](https://github.com/RobinBoers/Nindo) in Elixir using Phoenix for the web version and Ecto + PostgreSQL for the backend.

## Features

- Encrypted data
- Posts with images
- RSS support*
- Comments
- Profile data:
  - Avatar
  - Description
  - Display name

*Every users posts can be shared via a RSS feed and RSS can be included in your feed.

## Applications

This version of Nindo consists of a few applications:

- NinDB: Managing database, changesets and schemas
- Nindo (also called Nindo Core): Managing accounts, posts and all the other crap
- NindoPhx: Web client for Nindo
- NindoText: Terminal client for Nindo
