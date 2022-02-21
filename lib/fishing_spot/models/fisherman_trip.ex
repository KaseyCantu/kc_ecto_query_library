defmodule FishingSpot.FishermanTrip do
  alias FishingSpot.Fisherman
  alias FishingSpot.Trip

  use Ecto.Schema

  schema "fishermen_trips" do
    timestamps()
    belongs_to(:fisherman, Fisherman)
    belongs_to(:trip, Trip)
  end
end
