# Learning Ecto 

This is basically the TL;DR for my dive into Ecto. I always hate having to skim a long blog post looking for a quick answer, and I know you do too. With that in mind I'm going to make this post a list of common and not so common queries you can do with Ecto. I will keep it up-to-date as I discover more interesting queries and ways of using Ecto.

The repo with this post reproduced in the README can be found at [https://github.com/parkerl/ecto_query_library](https://github.com/parkerl/ecto_query_library). The queries below can be found in a usable form in `lib/fishing_spot/queries.ex`. If you find something incorrect please open a pull request. I would like to make this a community resource rather than my personal toolbox.

# Versions
_The query library is currently built using the following setup._

 - Elixir 1.12.1
 - Ecto 3.7
 - Postgres 13

# Table of Contents

- [Select Styles](#selects)
- [Select Distinct](#select_distinct)
- [Distinct on Expression](#distinct_expression)
- [Distinct with Order By](#distinct_order)
- [Max](#max)
- [Where](#where)
- [Count](#count)
- [Count Distinct](#count_distinct)
- [Group By with Max](#group_max)
- [Group By with Having](#group_having)
- [Limit](#limit)
- [Limit and Offset](#limit_offset)
- [Order By](#order)
- [Joins](#complex_where)
- [Joining with a Fragment](#max_join)
- [Max in two queries](#max_two_step)
- [Record with Max Value via Self Join](#max_self_join)
- [Record with Max Value via Subquery](#max_subquery)
- [Record with Max Value via Join Fragment](#max_join)
- [Keyword Where](#keyword_where)
- [Keyword Where Referencing Another Model](#keyword_another_model)
- [Where with In Clause](#where_in)
- [Where with Not In Clause](#where_not_in)
- [Complex Muti-join Multi-where](#complex_where)
- [Using a Select Fragment](#select_fragment)
- [Complex Select Logic Using a Fragment](#complex_select)
- [Partial-preloading](#partial_preload)
- [Binding Fun](#bindings)
- [Working with Prefixes](#prefixes)

-------------------------------------------------------------------

# <a name="selects"></a>Simple Queries with Different Select Styles
_Demonstrates how the various select styles change the return structure._

```elixir

# Default: The entire model comes back as a list of structs.
Repo.all(
  from fisherman in Fisherman
)

06:11:18.292 [debug] SELECT f0."id", f0."inserted_at", f0."updated_at", f0."name", f0."date_of_birth" FROM "fishermen" AS f0 [] OK query=0.5ms
[%FishingSpot.Fisherman{meta: #Ecto.Schema.Metadata<:loaded>,
  date_of_birth: #Ecto.Date<1970-01-02>,
  fish_landed: #Ecto.Association.NotLoaded<association :fish_landed is not loaded>,
  fishermen_trips: #Ecto.Association.NotLoaded<association :fishermen_trips is not loaded>,
  id: 1, inserted_at: #Ecto.DateTime<2015-09-29T12:05:05Z>, name: "Mark",
  trips: #Ecto.Association.NotLoaded<association :trips is not loaded>,
  updated_at: #Ecto.DateTime<2015-09-29T12:05:05Z>},

# The same as above. The entire model comes back as a list of structs.
Repo.all(
  from fisherman in Fisherman,
  select: fisherman
)

06:11:18.292 [debug] SELECT f0."id", f0."inserted_at", f0."updated_at", f0."name", f0."date_of_birth" FROM "fishermen" AS f0 [] OK query=0.5ms
[%FishingSpot.Fisherman{meta: #Ecto.Schema.Metadata<:loaded>,
  date_of_birth: #Ecto.Date<1970-01-02>,
  fish_landed: #Ecto.Association.NotLoaded<association :fish_landed is not loaded>,
  fishermen_trips: #Ecto.Association.NotLoaded<association :fishermen_trips is not loaded>,
  id: 1, inserted_at: #Ecto.DateTime<2015-09-29T12:05:05Z>, name: "Mark",
  trips: #Ecto.Association.NotLoaded<association :trips is not loaded>,
  updated_at: #Ecto.DateTime<2015-09-29T12:05:05Z>},

# Selects only the given fields. Returns a list of lists.
Repo.all(
  from fisherman in Fisherman,
  select: [fisherman.name, fisherman.date_of_birth]
)

06:11:18.305 [debug] SELECT f0."name", f0."date_of_birth" FROM "fishermen" AS f0 [] OK query=0.4ms
[["Mark", #Ecto.Date<1970-01-02>], ["Kirk", #Ecto.Date<1978-03-05>],
 ["Joe", #Ecto.Date<1973-10-15>], ["Lew", #Ecto.Date<1976-01-05>]]

# Selects only the given fields. Returns a list of tuples.
Repo.all(
  from fisherman in Fisherman,
  select: { fisherman.name, fisherman.date_of_birth }
)

06:11:18.306 [debug] SELECT f0."name", f0."date_of_birth" FROM "fishermen" AS f0 [] OK query=0.4ms
[{"Mark", #Ecto.Date<1970-01-02>}, {"Kirk", #Ecto.Date<1978-03-05>},
 {"Joe", #Ecto.Date<1973-10-15>}, {"Lew", #Ecto.Date<1976-01-05>}]

# Selects only the given fields. Returns a list of maps with data in the given keys.
Repo.all(
  from fisherman in Fisherman,
  select: %{ fisherman_name: fisherman.name, fisherman_dob: fisherman.date_of_birth }
)

06:11:18.307 [debug] SELECT f0."name", f0."date_of_birth" FROM "fishermen" AS f0 [] OK query=0.3ms
[%{fisherman_dob: #Ecto.Date<1970-01-02>, fisherman_name: "Mark"},
 %{fisherman_dob: #Ecto.Date<1978-03-05>, fisherman_name: "Kirk"},
 %{fisherman_dob: #Ecto.Date<1973-10-15>, fisherman_name: "Joe"},
 %{fisherman_dob: #Ecto.Date<1976-01-05>, fisherman_name: "Lew"}]
```

# <a name="select_distinct"></a>Select Distinct

```elixir
from fish in FishLanded,
select: fish.weight,
distinct: true

12:18:21.346 [debug] SELECT DISTINCT f0."weight" FROM "fish_landed" AS f0 [] OK query=9.5ms decode=3.0ms
```

# <a name="distinct_expression"></a>Distinct On Expression

```elixir
from fish in FishLanded,
distinct: fish.weight

2:26:59.260 [debug] SELECT DISTINCT ON (f0."weight") f0."id", f0."inserted_at", f0."updated_at", f0."date_and_time", f0."weight", f0."length", f0."fisherman_id", f0."location_id", f0."fly_type_id", f0."fish_species_id" FROM "fish_landed" AS f0 [] OK query=3.3ms decode=0.1ms queue=0.1ms

[%FishingSpot.FishLanded{__meta__: #Ecto.Schema.Metadata<:loaded>,
    date_and_time: #Ecto.DateTime<2012-06-12 21:51:26>,
    fish_species: #Ecto.Association.NotLoaded<association :fish_species is not loaded>,
    fish_species_id: 1,
    fisherman: #Ecto.Association.NotLoaded<association :fisherman is not loaded>,
    fisherman_id: 1,
    fly_type: #Ecto.Association.NotLoaded<association :fly_type is not loaded>,
    fly_type_id: 3, id: 886, inserted_at: #Ecto.DateTime<2016-02-18 04:51:26>,
    length: #Decimal<6>,
    location: #Ecto.Association.NotLoaded<association :location is not loaded>,
    location_id: 1, updated_at: #Ecto.DateTime<2016-02-18 04:51:26>,
    weight: #Decimal<1>},...
```

# <a name="distinct_order"></a>Distinct with Order By

```elixir
from fish in FishLanded,
distinct: fish.weight,
order_by: fish.date_and_time


12:37:15.371 [debug] SELECT DISTINCT ON (f0."weight") f0."id", f0."inserted_at", f0."updated_at", f0."date_and_time", f0."weight", f0."length", f0."fisherman_id", f0."location_id", f0."fly_type_id", f0."fish_species_id" FROM "fish_landed" AS f0
ORDER BY f0."weight", f0."date_and_time" [] OK query=4.9ms decode=0.2ms

[%FishingSpot.FishLanded{__meta__: #Ecto.Schema.Metadata<:loaded>,
    date_and_time: #Ecto.DateTime<2012-06-06 21:51:25>,
    fish_species: #Ecto.Association.NotLoaded<association :fish_species is not loaded>,
    fish_species_id: 2,
    fisherman: #Ecto.Association.NotLoaded<association :fisherman is not loaded>,
    fisherman_id: 3,
    fly_type: #Ecto.Association.NotLoaded<association :fly_type is not loaded>,
    fly_type_id: 2, id: 571, inserted_at: #Ecto.DateTime<2016-02-18 04:51:25>,
    length: #Decimal<1>,
    location: #Ecto.Association.NotLoaded<association :location is not loaded>,
    location_id: 2, updated_at: #Ecto.DateTime<2016-02-18 04:51:25>,
    weight: #Decimal<1>}, ...
```

# <a name="max"></a>Max

```elixir
from fish in FishLanded,
select: max(fish.length)
```

# <a name="where"></a>Simple Where

```elixir
from fish in FishLanded,
where: fish.length > 24
```

# <a name="count"></a>Count

```elixir
from fish in FishLanded,
select: count(fish.id),
where: fish.length > 24
```

# <a name="count_distinct"></a>Count Distinct

```elixir
from fish in FishLanded,
select: count(fish.fisherman_id, :distinct)
```

# <a name="group_max"></a>Group By with Max

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
group_by: fisherman.name,
select: [max(fish.length), fisherman.name]
```

# <a name="group_having"></a>Group By with Having

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
group_by: fisherman.name,
having: count(fish.id) > 15,
select: [max(fish.length), fisherman.name]
```

# <a name="limit"></a>Limit

```elixir
from fish in FishLanded,
limit: 10
```

# <a name="limit_offset"></a>Limit and Offset
_Demonstrates the use of limit and offset using a calculated value. Also, demonstrates the use of `Repo.aggregate/3`._

```elixir
fish_count = Repo.aggregate(FishLanded, :count, :id) |> div(2)

Repo.all(
 from fish in FishLanded,
 limit: 10,
 offset: ^fish_count
)

```

# <a name="order"></a>Order By
_Demonstrates ordering ascending and descending including keyword syntax._

```elixir
from fisherman in Fisherman,
order_by: fisherman.name,
select: fisherman.name

21:50:02.022 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name" [] OK query=4.0ms
["Joe", "Kirk", "Lew", "Mark"]

from fisherman in Fisherman,
order_by: [desc: fisherman.name],
select: fisherman.name

21:50:02.025 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name" DESC [] OK query=0.5ms
["Mark", "Lew", "Kirk", "Joe"]

from fisherman in Fisherman,
order_by: :name,
select: fisherman.name

21:50:02.022 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name" [] OK query=4.0ms
["Joe", "Kirk", "Lew", "Mark"]

from fisherman in Fisherman,
order_by: [desc: :name],
select: fisherman.name

21:50:02.025 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name" DESC [] OK query=0.5ms
["Mark", "Lew", "Kirk", "Joe"]

fields = [:name, :date_of_birth]
13:40:42.863 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name", f0."date_of_birth" [] OK query=0.2ms
from fisherman in Fisherman,
order_by: ^fields,
select: fisherman.name

13:40:42.863 [debug] SELECT f0."name" FROM "fishermen" AS f0 ORDER BY f0."name", f0."date_of_birth" [] OK query=0.2ms
```

# <a name="max_two_step"></a>Record with Max Value in Two Steps
_Demonstrates interpolating the result of one query into another._

```elixir
[big_fish] = Repo.all(
  from fish in FishLanded,
  select: max(fish.length)
 )

 Repo.all(
   from fish in FishLanded,
   join: fisherman in assoc(fish, :fisherman),
   where: fish.length == ^big_fish,
   select: [fish.length, fisherman.name]
 )
```

# <a name="max_self_join"></a>Record with Max Value via Self Join
_Demonstrates left joins, self joins, and conditions in joins. Calculates the
record with a maximum value by "folding" onto the same table._

```elixir
from fish in FishLanded,
left_join: bigger_fish in FishLanded, on: fish.length < bigger_fish.length,
join: fisherman in assoc(fish, :fisherman),
where: is_nil(bigger_fish.id),
select: [fish.length, fisherman.name]
```

# <a name="max_subquery"></a>Record with Max Value via Subquery
_Demonstrates subqueries in where clauses._

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
where: fragment(
    "? IN (SELECT MAX(biggest_fish.length) FROM fish_landed biggest_fish)", fish.length
  ),
select: [fish.length, fisherman.name]
```

# <a name="max_join"></a>Record with Max Value via Join Fragment
_Demonstrates the use of fragment in joins._

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
join: big_fish in fragment(
    "(SELECT MAX(biggest_fish.length) AS length FROM fish_landed biggest_fish)"
  ),
on: fish.length == big_fish.length,
select: [fish.length, fisherman.name]
```

# <a name="keyword_where"></a>Keyword Where
_Demonstrates the use of a keyword list for generating where clauses. Values are `AND`d. Also, shows that variables will be interpolated._

```elixir
    {_, date} = Ecto.Date.cast("1976-01-05")

    Repo.all(
      from fisherman in Fisherman,
      where: [name: "Lew", date_of_birth: ^date]
    )

    => SELECT f0."id", f0."inserted_at", f0."updated_at", f0."name", f0."date_of_birth"
    FROM "fishermen" AS f0
    WHERE ((f0."name" = 'Lew')
      AND (f0."date_of_birth" = $1))
      [{1976, 1, 5}]

    where(Fisherman, [name: "Lew", date_of_birth: ^date]) |> Repo.all

    => SELECT f0."id", f0."inserted_at", f0."updated_at", f0."name", f0."date_of_birth"
    FROM "fishermen" AS f0
    WHERE ((f0."name" = 'Lew')
      AND (f0."date_of_birth" = $1))
      [{1976, 1, 5}]
```

# <a name="keyword_another_model"></a>Keyword Where Referencing Another Model

_Demonstrates referencing another model in a keyword where clause. Also shows that no join condition is required by `join`. It defaults to `ON TRUE`._

```elixir
join(Fisherman, :inner, [], fish_landed in FishLanded)
  |> where([fisherman, fish_landed], [name: "Lew", date_of_birth: ^date, id: fish_landed.fisherman_id])
  |> Repo.all

=> SELECT f0."id", f0."inserted_at", f0."updated_at", f0."name", f0."date_of_birth"
FROM "fishermen" AS f0
INNER JOIN "fish_landed" AS f1 ON TRUE
WHERE (((f0."name" = 'Lew')
 AND (f0."date_of_birth" = $1))
 AND (f0."id" = f1."fisherman_id"))

[{1976, 1, 5}]
```

# <a name="where_in"></a>Where with In Clause

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
where: fisherman.name in ["Mark", "Kirk"],
group_by: fisherman.name,
order_by: fisherman.name,
select: %{biggest_fish: max(fish.length), fisherman: fisherman.name}
```

# <a name="where_not_in"></a>Where with Not In Clause
_Demonstrates the use of `not` to negate an in clause._

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
where: not fisherman.name in ["Mark", "Kirk"],
group_by: fisherman.name,
order_by: fisherman.name,
select: %{biggest_fish: max(fish.length), fisherman: fisherman.name}
```

# <a name="complex_where"></a>Complex Muti-join Multi-where

_Demonstrates joins, sub-querying and using map syntax in the select.
Uses the `date_add/3` function. Demonstrates how to accomplish a "between" where clause._

```elixir
from fish in FishLanded,
  join: fly_type in assoc(fish, :fly_type),
  join: fish_species in assoc(fish, :fish_species),
  join: fisherman in assoc(fish, :fisherman),
  join: trip in assoc(fisherman, :trips),
  join: locations in assoc(trip, :locations),
  join: location_types in assoc(locations, :location_type),
  where: fragment(
    "? IN (SELECT MAX(biggest_fish.length) FROM fish_landed biggest_fish)", fish.length
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
```

# <a name="select_fragment"></a>Using a Select Fragment
## with Named Grouping and Positional Ordering

_Demonstrates how to use a named column from a fragment or a positional
column from an aggregate function in grouping or ordering._

```elixir
from fish in FishLanded,
group_by: fragment("date"),
order_by: fragment("2"),
select: %{
  date: fragment("date_trunc('day', ?) AS date", field(fish, :date_and_time)),
  fish_count: count(fish.id)
}
```

# <a name="complex_select"></a>Complex Select Logic Using a Fragment

_Demonstrates how to use multiple columns to calculate a value.
Also orders descending using positional column selection._

```elixir
from fish in FishLanded,
join: fisherman in assoc(fish, :fisherman),
order_by: [desc: fragment("1")],
select: %{
  bool: fragment(
    "((? = 'Kirk' OR ? = 'Mark') AND NOT ? < 10) AS crazy_select",
    field(fisherman, :name),
    field(fisherman, :name),
    field(fish, :length)),
  fisherman: fisherman.name
}
```


# <a name="partial_preload"></a>Partial-preloading

_Demonstrates how to select only parts of a join model in a preload.
Uses both map and list select syntax._

```elixir
    query = Fisherman
        |> join(:inner, [fisherman], fish in assoc(fisherman, :fish_landed))
        |> where([fisherman], fisherman.id == 1)
        |> select([fisherman, fish], %{fisherman: fisherman, length: fish.length})
        |> preload([fisherman, fish], [fish_landed: fish])

    Repo.first(query).fisherman.fish_landed |> IO.inspect

    query = Fisherman
        |> join(:inner, [fisherman], fish in assoc(fisherman, :fish_landed))
        |> where([fisherman], fisherman.id == 1)
        |> select([fisherman, fish], %{fisherman: fisherman, length: fish.length})
        |> preload([fisherman, fish], [fish_landed: fish])

    fisherman = Repo.first(query) |> List.first
    fisherman.fish_landed |> IO.inspect
```

# <a name="bindings"></a>Binding Fun

_Demonstrates that bindings are order and not name dependent. See [http://www.glydergun.com/a-bit-about-bindings/](http://www.glydergun.com/a-bit-about-bindings/)._

```elixir
FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [fish, fly_type], fish_species in assoc(fish, :fish_species))
      |> join(:inner, [fish, fly_type, fish_type], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fly_type, fish_type, fisherman], trip in assoc(fisherman, :trips))
      |> join(:inner, [fish, fly_type, fish_type, fisherman, trip],
              locations in assoc(trip, :locations))
      |> join(:inner, [fish, fly_type, fish_type, fisherman, trip, location],
              location_types in assoc(location, :location_type))
      |> select([fish], count(fish.id))

FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [fish], fish_species in assoc(fish, :fish_species))
      |> join(:inner, [fish], fisherman in assoc(fish, :fisherman))
      |> join(:inner, [fish, fly_type, fish_type, fisherman],
              trip in assoc(fisherman, :trips))
      |> join(:inner, [fish, fly_type, fish_type, fisherman, trip],
              locations in assoc(trip, :locations))
      |> join(:inner, [fish, fly_type, fish_type, fisherman, trip, location],
              location_types in assoc(location, :location_type))
      |> select([fish], count(fish.id))

FishLanded
      |> join(:inner, [fish], fly_type in assoc(fish, :fly_type))
      |> join(:inner, [nemo], fish_species in assoc(nemo, :fish_species))
      |> join(:inner, [bait], fisherman in assoc(bait, :fisherman))
      |> join(:inner, [foo, bar, baz, ahab], trip in assoc(ahab, :trips))
      |> join(:inner, [foo, bar, baz, ahab, set_sail], locations in assoc(set_sail, :locations))
      |> join(:inner, [x, y, z, a, b, c], location_types in assoc(c, :location_type))
      |> select([whatever], count(whatever.id))
```

# <a name="prefixes"></a>Working with Prefixes
_Demonstrates how to work with schemas other than "public" in Postgres._

```elixir
# The migration
  def change do
    execute "CREATE SCHEMA users"

    create table(:accounts, prefix: :users) do
      add :identifier, :string
      add :name,       :string

      timestamps
    end
  end

# Inserting data
    Repo.insert(
      Ecto.Model.put_meta(
      %Account{ identifier: "lew@example.com",  name: "Lew"  },
      prefix: "users"
      )
    )
    Repo.insert(
      Ecto.Model.put_meta(
       %Account{ identifier: "mark@example.com", name: "Mark" },
       prefix: "users"
      )
    )
    Repo.insert(
     Ecto.Model.put_meta(
       %Account{ identifier: "john@example.com", name: "John" },
       prefix: "users"
     )
    )

#Querying
    query = from accounts in Account
    Repo.all(%{query | prefix: "users"})
```
