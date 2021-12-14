defmodule Nindo.Core do
  @moduledoc """
    Core helper methods for Nindo
  """

  alias Calendar.DateTime.{Format, Parse}
  alias Nindo.{Accounts}

  # Template helpers

  @doc """
    Mark string as save to render for Phoenix
  """
  def safe(txt), do: {:safe, txt}

  @doc """
    Convert markdown into safe HTML
  """
  def markdown(text) do
    text
    |> String.split("\n")
    |> Earmark.as_html()
    |> strip_ok()
    |> HtmlSanitizeEx.basic_html()
  end

  # Date and time

  @doc """
    Get current NaiveDateTime without seconds
  """
  def datetime() do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  @doc """
    Convert current NaiveDateTime into human readable format
  """
  def human_datetime(d) do
    "#{d.day}/#{d.month}/#{d.year}"
  end

  @doc """
    Get current NaiveDateTime in human readable format
  """
  def now() do
    human_datetime datetime()
  end

  @doc """
    Convert NaiveDateTime into the RFC822 format used by RSS
  """
  def to_rfc822(datetime) do
    datetime
    |> NaiveDateTime.to_erl()
    |> Calendar.DateTime.from_erl!("Etc/UTC")
    |> Format.rfc2822()
  end

  @doc """
    Convert RFC822 DateTime format into NaiveDateTime
  """
  def from_rfc822(datetime) do
    {:ok, datetime} =
      datetime
      |> Parse.rfc2822_utc()

    DateTime.to_naive(datetime)
  end

  @doc """
    Reverse `NaiveDateTime.to_string/1`
  """
  def from_string(datetime) do
    [date, time] = String.split(datetime, " ")

    {:ok, date} = Date.from_iso8601(date)
    {:ok, time} = Time.from_iso8601(time)
    {:ok, datetime} = NaiveDateTime.new(date, time)

    datetime
  end

  # User and session managment

  @doc """
    Check if the user is logged in
  """
  def logged_in?(conn) do
    conn.private.plug_session["logged_in"] == true
  end

  @doc """
    Get currently logged in user
  """
  def user(conn) do
    Accounts.get conn.private.plug_session["user_id"]
  end

  @doc """
    Check for dev/testing mode
  """
  def debug_mode?(), do: false
    # To use mix: Mix.env() in [:dev, :test]

  defp strip_ok({:ok, data}), do: data
  defp strip_ok({:ok, data, _}), do: data
end
