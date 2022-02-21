defmodule FishingSpot.LocationTrip do
  use Ecto.Schema
  alias FishingSpot.Location
  alias FishingSpot.Trip

  schema "locations_trips" do
    timestamps()
    belongs_to(:location, Location)
    belongs_to(:trip, Trip)
  end
end
