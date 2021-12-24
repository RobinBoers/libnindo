defmodule Nindo.Format do
  @moduledoc false

  alias Nindo.{Accounts}
  import Nindo.Core

  @not_available "<i>No account description available.</i>"

  def profile_picture(username) do
    case Accounts.get_by(:username, username).profile_picture do
      nil             ->    default_profile_picture(username)
      profile_picture ->    profile_picture
    end
  end

  def description(username) when is_binary(username) do
    case Accounts.get_by(:username, username).description do
      nil             ->    safe @not_available
      description     ->    description
    end
  end

  def description(account) do
    case account.description do
      nil             ->    safe @not_available
      description     ->    description
    end
  end

  def display_name(username) when is_binary(username) do
    case Accounts.get_by(:username, username).display_name do
      nil             ->    String.capitalize username
      display_name    ->    display_name
    end
  end

  def display_name(account) do
    case account.display_name do
      nil             ->    String.capitalize account.username
      display_name    ->    display_name
    end
  end

  def default_profile_picture(username), do: "https://avatars.dicebear.com/api/identicon/#{username}.svg?scale=80&b=%23E5E7EB"
  def default_profile_picture(), do: "/images/empty.png"

end
