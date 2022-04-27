defmodule Nindo.Core do
  @moduledoc false

  alias Calendar.DateTime.{Format, Parse}
  alias Nindo.{Accounts}

  # Template helpers

  def safe(txt), do: {:safe, txt}

  def markdown(text) do
    text
    |> String.split("\n")
    |> Earmark.as_html()
    |> strip_ok()
    |> HtmlSanitizeEx.basic_html()
  end

  # Date and time

  def now() do
    human_datetime datetime()
  end

  def datetime() do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  def human_datetime(d) do
    "#{d.day}/#{d.month}/#{d.year}"
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

  def from_string(datetime) do
    [date, time] = String.split(datetime, " ")

    {:ok, date} = Date.from_iso8601(date)
    {:ok, time} = Time.from_iso8601(time)
    {:ok, datetime} = NaiveDateTime.new(date, time)

    datetime
  end

  # User and session managment

  def logged_in?(conn) when conn.private != nil do
    conn.private.plug_session["logged_in?"] == true
  end
  def logged_in?(session) do
    session["logged_in?"] == true
  end

  def user(conn) when conn.private != nil do
    case conn.private.plug_session["user_id"] do
      nil -> nil
      id -> Accounts.get id
    end
  end
  def user(session) do
    case session["user_id"] do
      nil -> nil
      id -> Accounts.get id
    end
  end

  # Other

  def debug_mode?(), do: false

  def format_error(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, _acc ->
      joined_errors = Enum.join(v, "; ")
      String.capitalize("#{k}: #{joined_errors}")
    end)
  end

  def strip_ok({:ok, data}), do: data
  def strip_ok({:ok, data, _}), do: data
end
