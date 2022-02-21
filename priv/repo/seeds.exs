defmodule FishingSpot.Data do
  alias Decimal, as: D
  alias FishingSpot.Repo
  alias FishingSpot.Location
  alias FishingSpot.LocationTrip
  alias FishingSpot.LocationType
  alias FishingSpot.Fisherman
  alias FishingSpot.FishermanTrip
  alias FishingSpot.FishLanded
  alias FishingSpot.FishSpecies
  alias FishingSpot.FlyType
  alias FishingSpot.Trip
  alias FishingSpot.Account

  defmodule RandomizedAttributes do
    defstruct fisherman: nil, location: nil, fly: nil, trip: nil, fish: nil, length: nil, weight: nil, date_and_time_caught: nil
  end

  def generate do
    Logger.disable(self())
    _generate()
    Logger.enable(self())
  end

  defp _generate do
    IO.puts "Generating data"

    rainbow_trout   = Repo.insert! %FishSpecies{  name: "Rainbow Trout"   }
    brown_trout     = Repo.insert! %FishSpecies{  name: "Brown Trout"     }
    lake_trout      = Repo.insert! %FishSpecies{  name: "Lake Trout"      }
    brook_trout     = Repo.insert! %FishSpecies{  name: "Brook Trout"     }
    cutthroat_trout = Repo.insert! %FishSpecies{  name: "Cutthroat Trout" }

    fish_types = [rainbow_trout, brown_trout, lake_trout, brook_trout, cutthroat_trout]

    muddler      = Repo.insert! %FlyType{  name: "Muddler Minnow" }
    hares_ear    = Repo.insert! %FlyType{  name: "Hare's' Ear"      }
    copper_john  = Repo.insert! %FlyType{  name: "Copper John"    }
    royal_wulff  = Repo.insert! %FlyType{  name: "Royal Wulff"    }
    morning_dunn = Repo.insert! %FlyType{  name: "Morning Dunn"   }

    flies = [muddler, hares_ear, copper_john, royal_wulff, morning_dunn]

    lake         = Repo.insert! %LocationType{  name: "Lake"         }
    pond         = Repo.insert! %LocationType{  name: "Pond"         }
    spring_creek = Repo.insert! %LocationType{  name: "Spring Creek" }
    _stream      = Repo.insert! %LocationType{  name: "Stream"       }
    river        = Repo.insert! %LocationType{  name: "River"        }
    tail_water   = Repo.insert! %LocationType{  name: "Tail Water"   }

    mark = Repo.insert! %Fisherman{ name: "Mark",  date_of_birth: ~D[1970-01-01] }
    kirk = Repo.insert! %Fisherman{ name: "Kirk",  date_of_birth: ~D[1978-03-05] }
    joe  = Repo.insert! %Fisherman{ name: "Joe",   date_of_birth: ~D[1973-10-15] }
    lew  = Repo.insert! %Fisherman{ name: "Lew",   date_of_birth: ~D[1976-01-05] }

    fishermen = [mark, kirk, joe, lew]

    trip1 = Repo.insert! %Trip{ start_date: ~D[2012-06-05], end_date: ~D[2012-06-12] }
    trip2 = Repo.insert! %Trip{ start_date: ~D[2012-10-15], end_date: ~D[2012-10-20] }
    trip3 = Repo.insert! %Trip{ start_date: ~D[2013-09-01], end_date: ~D[2013-09-02] }
    trip4 = Repo.insert! %Trip{ start_date: ~D[2014-07-15], end_date: ~D[2014-07-20] }
    trip5 = Repo.insert! %Trip{ start_date: ~D[2014-08-08], end_date: ~D[2014-08-18] }

    trips = [trip1, trip2, trip3, trip4, trip5]

    lake_fork   = Repo.insert! %Location{name: "Lake Fork",               altitude: 8000,  lat: D.new("38.090942"),  long: D.new("-107.292869"),  location_type_id: river.id        }
    blue_mesa   = Repo.insert! %Location{name: "Blue Mesa",               altitude: 7000,  lat: D.new("38.472406"),  long: D.new("-107.210268"),  location_type_id: lake.id         }
    main_elk    = Repo.insert! %Location{name: "Main Elk Creek",          altitude: 7000,  lat: D.new("39.729579"),  long: D.new("-107.545462"),  location_type_id: spring_creek.id }
    frying_pan  = Repo.insert! %Location{name: "Frying Pan Tailwater",    altitude: 6000,  lat: D.new("39.363448"),  long: D.new("-106.823121"),  location_type_id: tail_water.id   }
    unamed_pond = Repo.insert! %Location{name: "Unamed Pond",             altitude: 5000,  lat: D.new("39.887929"),  long: D.new("-107.354998"),  location_type_id: pond.id         }
    white_river = Repo.insert! %Location{name: "North Fork White River",  altitude: 5000,  lat: D.new("40.051879"),  long: D.new("-107.458016"),  location_type_id: pond.id         }

    locations = [lake_fork, blue_mesa, main_elk, frying_pan, unamed_pond, white_river]

    Repo.insert! %LocationTrip{location_id: lake_fork.id,    trip_id: trip1.id}
    Repo.insert! %LocationTrip{location_id: blue_mesa.id,    trip_id: trip1.id}
    Repo.insert! %LocationTrip{location_id: main_elk.id,     trip_id: trip2.id}
    Repo.insert! %LocationTrip{location_id: frying_pan.id,   trip_id: trip2.id}
    Repo.insert! %LocationTrip{location_id: lake_fork.id,    trip_id: trip3.id}
    Repo.insert! %LocationTrip{location_id: blue_mesa.id,    trip_id: trip3.id}
    Repo.insert! %LocationTrip{location_id: main_elk.id,     trip_id: trip4.id}
    Repo.insert! %LocationTrip{location_id: frying_pan.id,   trip_id: trip4.id}
    Repo.insert! %LocationTrip{location_id: unamed_pond.id,  trip_id: trip4.id}
    Repo.insert! %LocationTrip{location_id: white_river.id,  trip_id: trip4.id}
    Repo.insert! %LocationTrip{location_id: lake_fork.id,    trip_id: trip5.id}

    Repo.insert! %FishermanTrip{fisherman_id: lew.id  , trip_id: trip1.id}
    Repo.insert! %FishermanTrip{fisherman_id: lew.id  , trip_id: trip2.id}
    Repo.insert! %FishermanTrip{fisherman_id: lew.id  , trip_id: trip3.id}
    Repo.insert! %FishermanTrip{fisherman_id: lew.id  , trip_id: trip4.id}
    Repo.insert! %FishermanTrip{fisherman_id: lew.id  , trip_id: trip5.id}
    Repo.insert! %FishermanTrip{fisherman_id: kirk.id , trip_id: trip4.id}
    Repo.insert! %FishermanTrip{fisherman_id: kirk.id , trip_id: trip5.id}
    Repo.insert! %FishermanTrip{fisherman_id: joe.id  , trip_id: trip1.id}
    Repo.insert! %FishermanTrip{fisherman_id: joe.id  , trip_id: trip5.id}
    Repo.insert! %FishermanTrip{fisherman_id: mark.id , trip_id: trip1.id}
    Repo.insert! %FishermanTrip{fisherman_id: mark.id , trip_id: trip2.id}
    Repo.insert! %FishermanTrip{fisherman_id: mark.id , trip_id: trip3.id}


    Enum.each(1..1000, fn(_) ->
      attributes = get_fish_attributes(30, 5, fishermen, locations, flies, trips, fish_types)
      Repo.insert %FishLanded{date_and_time: attributes.date_and_time_caught, weight: attributes.weight, length: attributes.length, fisherman_id: attributes.fisherman.id, location_id: attributes.location.id, fly_type_id: attributes.fly.id, fish_species_id: attributes.fish.id}
    end)

    attributes = get_fish_attributes(30, 5, fishermen, locations, flies, trips, fish_types)
    Repo.insert %FishLanded{date_and_time: attributes.date_and_time_caught, weight: D.new(:rand.uniform(50)), length: D.new(:rand.uniform(100)), fisherman_id: mark.id, location_id: attributes.location.id, fly_type_id: attributes.fly.id, fish_species_id: attributes.fish.id}
    attributes = get_fish_attributes(30, 5, fishermen, locations, flies, trips, fish_types)
    Repo.insert %FishLanded{date_and_time: attributes.date_and_time_caught, weight: D.new(:rand.uniform(50)), length: D.new(:rand.uniform(100)), fisherman_id: kirk.id, location_id: attributes.location.id, fly_type_id: attributes.fly.id, fish_species_id: attributes.fish.id}
    attributes = get_fish_attributes(30, 5, fishermen, locations, flies, trips, fish_types)
    Repo.insert %FishLanded{date_and_time: attributes.date_and_time_caught, weight: D.new(:rand.uniform(50)), length: D.new(:rand.uniform(100)), fisherman_id: lew.id, location_id: attributes.location.id, fly_type_id: attributes.fly.id, fish_species_id: attributes.fish.id}
    attributes = get_fish_attributes(30, 5, fishermen, locations, flies, trips, fish_types)
    Repo.insert %FishLanded{date_and_time: attributes.date_and_time_caught, weight: D.new(:rand.uniform(50)), length: D.new(:rand.uniform(100)), fisherman_id: joe.id, location_id: attributes.location.id, fly_type_id: attributes.fly.id, fish_species_id: attributes.fish.id}


    Repo.insert Ecto.put_meta( %Account{ identifier: "kasey@example.com",  name: "Kasey"  }, prefix: "users" )
    Repo.insert Ecto.put_meta( %Account{ identifier: "alexis@example.com", name: "Alexis" }, prefix: "users" )
    Repo.insert Ecto.put_meta( %Account{ identifier: "apollo@example.com", name: "Apollo" }, prefix: "users" )
  end

  def get_fish_attributes(max_length, max_weight, fishermen, locations, flies, _trips, fish_types) do
    :rand.seed(:exs64)
    fisherman           = Enum.shuffle(fishermen                 ) |> List.first
    fisherman           = Repo.preload(fisherman, :trips         )
    location            = Enum.shuffle(locations                 ) |> List.first
    fly                 = Enum.shuffle(flies                     ) |> List.first
    trip                = Enum.shuffle(fisherman.trips           ) |> List.first
    fish                = Enum.shuffle(fish_types                ) |> List.first
    length              = D.new(:rand.uniform(max_length ) )
    weight              = D.new(:rand.uniform(max_weight ) )

    %Date{year: year, month: month, day: trip_start} = trip.start_date
    %Date{day: trip_end}                             = trip.end_date

    trip_length                 = trip_end - trip_start
    day_caught                  = :rand.uniform(trip_length)
    {:ok, date_caught}          = Date.new(year, month, trip_start + day_caught)
    {:ok, naive_date_and_time_caught} = NaiveDateTime.new(date_caught, Time.utc_now())
    truncated_date_caught       = NaiveDateTime.truncate(naive_date_and_time_caught, :second)

    %RandomizedAttributes{
      fisherman:    fisherman,
      location:  location,
      fly:       fly,
      trip:      trip,
      fish:      fish,
      length:    length,
      weight:    weight,
      date_and_time_caught: truncated_date_caught
    }
  end
end

FishingSpot.Data.generate
