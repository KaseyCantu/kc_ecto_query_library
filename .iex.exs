import_file_if_available("~/.iex.exs")

import Ecto.Query

alias FishingSpot.Repo
alias FishingSpot.Location
alias FishingSpot.LocationTrip
alias FishingSpot.LocationType
alias FishingSpot.Fisherman
alias FishingSpot.PersonTrip
alias FishingSpot.FishLanded
alias FishingSpot.FishSpecies
alias FishingSpot.FlyType
alias FishingSpot.Trip
alias FishingSpot.Queries
alias FishingSpot.Account

q = fn -> c("lib/fishing_spot/queries.ex") end
