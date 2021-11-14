defmodule Nindo.Core do
  @moduledoc false

  alias Calendar.DateTime.{Format, Parse}
  alias Nindo.{Accounts}

  # Template helpers

  def safe(txt), do: {:safe, txt}

  # Date and time

  def datetime() do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  def human_datetime(d) do
    "#{d.day}/#{d.month}/#{d.year}"
  end

  def now() do
    human_datetime datetime()
  end

  def to_rfc822(datetime) do
    datetime
    |> NaiveDateTime.to_erl()
    |> Calendar.DateTime.from_erl!("Etc/UTC")
    |> Format.rfc2822()
  end

  def from_rfc822(datetime) do
    {:ok, datetime} =
      datetime
      |> Parse.rfc2822_utc()

    DateTime.to_naive(datetime)
  end

  # User and session managment

  def logged_in?(conn) do
    conn.private.plug_session["logged_in"] == true
  end

  def user(conn) do
    Accounts.get conn.private.plug_session["user_id"]
  end

  def debug_mode(), do: true

end
