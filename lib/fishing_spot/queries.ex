defmodule FishingSpot.Queries do
  alias FishingSpot.Repo
  alias FishingSpot.FishLanded
  alias FishingSpot.Fisherman
  alias FishingSpot.Account

  import Ecto.Query

  @moduledoc """
  Welcome to the Ecto Query Library!
  """

  @doc """
  Selects all `Fisherman` records from the database.
  """
  def all_fishermen do
    Repo.all(from(fisherman in Fisherman)) |> IO.inspect()

    Repo.all(
      from(fisherman in Fisherman,
        select: fisherman
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fisherman in Fisherman,
        select: [fisherman.name, fisherman.date_of_birth]
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fisherman in Fisherman,
        select: {fisherman.name, fisherman.date_of_birth}
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fisherman in Fisherman,
        select: %{fisherman_name: fisherman.name, fisherman_dob: fisherman.date_of_birth}
      )
    )
    |> IO.inspect()
  end

  def ordered_fishermen do
    Repo.all(
      from(fisherman in Fisherman,
        order_by: fisherman.name,
        select: fisherman.name
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fisherman in Fisherman,
        order_by: [desc: fisherman.name],
        select: fisherman.name
      )
    )

    Repo.all(
      from(fisherman in Fisherman,
        order_by: :name,
        select: fisherman.name
      )
    )

    Repo.all(
      from(fisherman in Fisherman,
        order_by: [desc: :name],
        select: fisherman.name
      )
    )

    fields = [:name, :date_of_birth]

    Repo.all(
      from(fisherman in Fisherman,
        order_by: ^fields,
        select: fisherman.name
      )
    )
  end

  def biggest_fish do
    Repo.all(
      from(fish in FishLanded,
        select: max(fish.length)
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fish in FishLanded,
        select: {max(fish.length)}
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fish in FishLanded,
        select: [max(fish.length)]
      )
    )
    |> IO.inspect()

    Repo.all(
      from(fish in FishLanded,
        select: %{big_fish: max(fish.length)}
      )
    )
  end

  def fishy_fish do
    Repo.all(
      from(fish in FishLanded,
        where: fish.length > 24
      )
    )
  end

  def fisherman_by_keyword do
    date = ~D[1993-06-22]

    Repo.all(
      from(fisherman in Fisherman,
        where: [name: "Kasey", date_of_birth: ^date]
      )
    )

    where(Fisherman, name: "Kasey", date_of_birth: ^date) |> Repo.all()

    join(Fisherman, :inner, [], fish_landed in FishLanded)
    |> where([fisherman, fish_landed],
      name: "Kasey",
      date_of_birth: ^date,
      id: fish_landed.fisherman_id
    )
    |> Repo.all()

    nil
  end

  def fishy_fish_count do
    Repo.all(
      from(fish in FishLanded,
        select: count(fish.id),
        where: fish.length > 24
      )
    )
  end

  def biggest_fish_per_fisherman do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        group_by: fisherman.name,
        select: [max(fish.length), fisherman.name]
      )
    )
  end

  def biggest_fish_per_fisherman_ordered do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        group_by: fisherman.name,
        order_by: fisherman.name,
        select: %{biggest_fish: max(fish.length), fisherman: fisherman.name}
      )
    )
  end

  def biggest_fish_per_fisherman_in_clause do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        where: fisherman.name in ["Alexis", "Apollo"],
        group_by: fisherman.name,
        order_by: fisherman.name,
        select: %{biggest_fish: max(fish.length), fisherman: fisherman.name}
      )
    )
  end

  def biggest_fish_per_fisherman_not_in_clause do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        where: fisherman.name not in ["Alexis", "Apollo"],
        group_by: fisherman.name,
        order_by: fisherman.name,
        select: %{biggest_fish: max(fish.length), fisherman: fisherman.name}
      )
    )
  end

  def biggest_fish_per_fisherman_two_queries do
    [big_fish] =
      Repo.all(
        from(fish in FishLanded,
          select: max(fish.length)
        )
      )

    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        where: fish.length == ^big_fish,
        select: [fish.length, fisherman.name]
      )
    )
  end

  def biggest_fish_catcher do
    Repo.all(
      from(fish in FishLanded,
        left_join: bigger_fish in FishLanded,
        on: fish.length < bigger_fish.length,
        join: fisherman in assoc(fish, :fisherman),
        where: is_nil(bigger_fish.id),
        select: [fish.length, fisherman.name]
      )
    )
  end

  def biggest_fish_catcher_in_clause do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        where:
          fragment(
            "? IN (SELECT MAX(biggest_fish.length) FROM fish_landed biggest_fish)",
            fish.length
          ),
        select: [fish.length, fisherman.name]
      )
    )
  end

  def biggest_fish_catcher_join do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        join:
          big_fish in fragment(
            "(SELECT MAX(biggest_fish.length) AS length FROM fish_landed biggest_fish)"
          ),
        on: fish.length == big_fish.length,
        select: [fish.length, fisherman.name]
      )
    )
  end

  def biggest_fish_details do
    query =
      from(fish in FishLanded,
        join: fly_type in assoc(fish, :fly_type),
        join: fish_species in assoc(fish, :fish_species),
        join: fisherman in assoc(fish, :fisherman),
        join: trip in assoc(fisherman, :trips),
        join: locations in assoc(trip, :locations),
        join: location_types in assoc(locations, :location_type),
        where:
          fragment(
            "? IN (SELECT MAX(biggest_fish.length) FROM fish_landed biggest_fish)",
            fish.length
          ),
        where: fish.date_and_time >= trip.start_date,
        where: fish.date_and_time <= date_add(trip.end_date, 1, "day"),
        select: %{
          length: fish.length,
          date_caught: fish.date_and_time,
          fish_type: fish_species.name,
          fly: fly_type.name,
          fisherman: fisherman.name,
          trip_start: trip.start_date,
          trip_end: trip.end_date,
          location: locations.name,
          location_type: location_types.name
        }
      )

    Repo.one(first(query))
  end

  def complex_select_fragment do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        order_by: [desc: fragment("1")],
        select: %{
          bool:
            fragment(
              "((? = 'Apollo' OR ? = 'Alexis') AND NOT ? < 10) AS crazy_select",
              field(fisherman, :name),
              field(fisherman, :name),
              field(fish, :length)
            ),
          fisherman: fisherman.name
        }
      )
    )
  end

  def fish_per_day do
    Repo.all(
      from(fish in FishLanded,
        group_by: fragment("date"),
        order_by: fragment("2"),
        select: %{
          date: fragment("date_trunc('day', ?) AS date", field(fish, :date_and_time)),
          fish_count: count(fish.id)
        }
      )
    )
  end

  def composed_biggest_fish_details do
    query =
      FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [fish, fly_type], fish_species in assoc(fish, :fish_species))
      |> join(:inner, [fish, fly_type, fish_type], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fly_type, fish_type, fisherman], trip in assoc(fisherman, :trips))
      |> join(
        :inner,
        [fish, fly_type, fish_type, fisherman, trip],
        locations in assoc(trip, :locations)
      )
      |> join(
        :inner,
        [fish, fly_type, fish_type, fisherman, trip, location],
        location_types in assoc(location, :location_type)
      )
      |> select([fish], count(fish.id))

    IO.inspect(query)
    Repo.all(query)

    query =
      FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [fish], fish_species in assoc(fish, :fish_species))
      |> join(:inner, [fish], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fly_type, fish_type, fisherman], trip in assoc(fisherman, :trips))
      |> join(
        :inner,
        [fish, fly_type, fish_type, fisherman, trip],
        locations in assoc(trip, :locations)
      )
      |> join(
        :inner,
        [fish, fly_type, fish_type, fisherman, trip, location],
        location_types in assoc(location, :location_type)
      )
      |> select([fish], count(fish.id))

    IO.inspect(query)
    Repo.all(query)

    query =
      FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [nemo], fish_species in assoc(nemo, :fish_species))
      |> join(:inner, [bait], fisherman in assoc(bait, :fisherman))
      |> join(:inner, [foo, bar, baz, ahab], trip in assoc(ahab, :trips))
      |> join(:inner, [foo, bar, baz, ahab, set_sail], locations in assoc(set_sail, :locations))
      |> join(:inner, [x, y, z, a, b, c], location_types in assoc(c, :location_type))
      |> select([whatever], count(whatever.id))

    IO.inspect(query)
    Repo.all(query)

    query =
      FishLanded
      |> join(:inner, [fish, foo, bar, baz], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fisherman], trip in assoc(fisherman, :trips))
      |> join(:inner, [fish, fisherman, trips], locations in assoc(trips, :locations))
      |> select([fish], count(fish.id))

    IO.inspect(query)
    Repo.all(query)

    query =
      FishLanded
      |> join(:inner, [fish], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fisherman], trip in assoc(fisherman, :trips))
      |> select([fish], count(fish.id))

    IO.inspect(query)
    Repo.all(query)
  end

  def select_associated do
    query =
      Fisherman
      |> join(:inner, [fisherman], fish in assoc(fisherman, :fish_landed))
      |> where([fisherman], fisherman.id == 1)
      |> select([fisherman, fish], %{fisherman: fisherman, length: fish.length})
      |> preload([fisherman, fish], fish_landed: fish)

    Repo.one(first(query)).fisherman.fish_landed |> IO.inspect()

    query =
      Fisherman
      |> join(:inner, [fisherman], fish in assoc(fisherman, :fish_landed))
      |> where([fisherman], fisherman.id == 1)
      |> select([fisherman, fish], %{fisherman: fisherman, length: fish.length})
      |> preload([fisherman, fish], fish_landed: fish)

    fisherman = Repo.one(query) |> Map.get(:fisherman)
    fisherman.fish_landed |> IO.inspect()
  end

  def prefixed do
    query = from(accounts in Account)
    Repo.all(%{query | prefix: "users"})
  end

  def distinct_fish_weight do
    query =
      from(fish in FishLanded,
        select: fish.weight,
        distinct: true
      )

    Repo.all(query)
  end

  def distinct_fish_weight_with_expression do
    query =
      from(fish in FishLanded,
        distinct: fish.weight
      )

    Repo.all(query)
  end

  def distinct_fish_weight_with_order_by do
    query =
      from(fish in FishLanded,
        distinct: fish.weight,
        order_by: fish.date_and_time
      )

    Repo.all(query)
  end

  def biggest_fish_per_fisherman_having do
    Repo.all(
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        group_by: fisherman.name,
        having: count(fish.id) > 15,
        select: [max(fish.length), fisherman.name]
      )
    )
  end

  def all_fish_limit_10 do
    Repo.all(
      from(fish in FishLanded,
        limit: 10
      )
    )
  end

  def all_fish_limit_10_offset_half do
    fish_count = Repo.aggregate(FishLanded, :count, :id) |> div(2)

    Repo.all(
      from(fish in FishLanded,
        limit: 10,
        offset: ^fish_count
      )
    )
  end

  def composed_keyword_queries do
    query =
      from(fish in FishLanded,
        join: fisherman in assoc(fish, :fisherman),
        where: fish.length > 10
      )

    query =
      from(fish in query,
        join: fly in assoc(fish, :fly_type),
        join: fisherman in assoc(fish, :fisherman),
        where: fly.name == "Muddler Minnow",
        where: fisherman.name == "Alexis",
        where: fish.weight > 10,
        select: [fisherman.name]
      )

    Repo.all(query)
  end
end
