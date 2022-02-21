defmodule FishingSpot.Repo do
  use Ecto.Repo,
    otp_app: :fishing_spot,
    adapter: Ecto.Adapters.Postgres
end
