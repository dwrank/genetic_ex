defmodule GeneticEx.OneMax do
  alias GeneticEx.Genetic

  def run(caller, status_interval) do
    alg = %{
      status: %{
        interval: status_interval,
        send_fn: fn status -> send(caller, status) end
      },
      genotype: fn -> for _ <- 1..1000, do: Enum.random(0..1) end,
      fitness_fn: fn chromosome -> Enum.sum(chromosome) end,
      max_fitness: 1000,
    }

    Genetic.run(alg)
  end
end
