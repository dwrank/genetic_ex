defmodule GeneticEx.Genetic do
  def run(alg) do
    initialize(alg)
    |> evolve(alg)
  end

  def initialize(alg) do
    for _ <- 1..100, do: alg.genotype.()
  end

  def evolve(population, alg, i \\ 1) do
    population = evaluate(population, alg)
    best = hd(population)
    fitness = alg.fitness_fn.(best)

    if fitness == alg.max_fitness do
      if is_function alg.status.send_fn do
        status = %{pid: self(), iters: i, best: best, fitness: fitness, state: :done}
        alg.status.send_fn.(status)
      end

      best
    else
      if is_function(alg.status.send_fn)
      && (alg.status.interval > 0)
      && rem(i, alg.status.interval) == 0 do
        status = %{pid: self(), iters: i, best: best, fitness: fitness, state: :running}
        alg.status.send_fn.(status)
      end

      population
      |> select()
      |> crossover()
      |> mutation()
      |> evolve(alg, i+1)
    end
  end

  def evaluate(population, alg) do
    Enum.sort_by(population, alg.fitness_fn, &>=/2)
  end

  def select(population) do
    population
    |> Stream.chunk_every(2)
    |> Stream.map(&List.to_tuple/1)
  end

  def crossover(stream) do
    Enum.reduce(stream, [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1))
        {h1, t1} = Enum.split(p1, cx_point)
        {h2, t2} = Enum.split(p2, cx_point)
        [h1 ++ t2, h2 ++ t1 | acc]
      end
    )
  end

  def mutation(population) do
    Enum.map(population,
      fn chromosome ->
        if :rand.uniform() < 0.05 do
          Enum.shuffle(chromosome)
        else
          chromosome
        end
      end)
  end
end
