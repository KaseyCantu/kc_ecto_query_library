defmodule FishingSpot do
  use Application
  use DynamicSupervisor

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @impl true
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(FishingSpot.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FishingSpot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end
end
