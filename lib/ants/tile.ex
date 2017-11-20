defmodule Ants.Tile do
  use GenServer

  alias Ants.Utils

  ## Consts

  @starting_food 10
  @pheromone_decay 0.1

  ## Structs

  defmodule Land do
    defstruct pheromone: 0
  end

  defmodule Rock do
    defstruct []
  end

  defmodule Home do
    defstruct food: 0
  end

  defmodule Food do
    defstruct food: 0
  end

  ## Client

  def start_link(type, opts) do
    GenServer.start_link(__MODULE__, type, opts)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def add_pheromone(pid) do
    GenServer.call(pid, :add_pheromone)
  end

  def take_food(pid) do
    GenServer.call(pid, :take_food)
  end

  def deposit_food(pid) do
    GenServer.call(pid, :deposit_food)
  end

  def tick(pid) do
    GenServer.cast(pid, :tick)
  end

  ## Server 
  
  def init(:land), do: {:ok, %Land{}}
  def init(:rock), do: {:ok, %Rock{}}
  def init(:home), do: {:ok, %Home{}}
  def init(:food), do: {:ok, %Food{food: @starting_food}}
  def init(_),     do: {:error, :bad_type}

  def handle_call(:get, _from, tile) do
    {:reply, tile, tile}
  end


  def handle_call(:take_food, _from, tile = %Food{food: food}) when food > 1 do
    {:reply, {:ok, 1}, Map.update!(tile, :food, &Utils.dec/1)} 
  end

  def handle_call(:take_food, _from, tile = %Food{}) do
    {:reply, {:ok, 1}, %Land{}} 
  end

  def handle_call(:take_food, _from, tile) do
    {:reply, {:error, :not_food}, tile}
  end


  def handle_call(:add_pheromone, _from, tile = %Land{pheromone: pheromone}) do
    {:reply, {:ok}, Map.update!(tile, :pheromone, &Utils.inc/1)}
  end

  def handle_call(:add_pheromone, _from, tile) do
    {:reply, {:error, :not_land}, tile}
  end


  def handle_call(:deposit_food, _from, tile = %Home{}) do
    {:reply, {:ok}, Map.update!(tile, :food, &Utils.inc/1)}
  end

  def handle_call(:deposit_food, _from, tile) do
    {:reply, {:error, :not_home}, tile}
  end

  
  def handle_cast(:tick, _from, tile = %Land{pheromone: pheromone}) when pheromone > 0 do
    {:noreply, %Land{pheromone: pheromone * @pheromone_decay}}
  end

  def handle_cast(:tick, _from, tile) do
    {:noreply, tile}
  end
end