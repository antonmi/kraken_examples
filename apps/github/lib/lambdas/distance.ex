defmodule Github.Lambdas.Distance do
  def closest(%{"name" => name, "names" => names}) do
    closest = Enum.min_by(names, &Levenshtein.distance(&1, name))
    %{"closest" => closest}
  end
end
