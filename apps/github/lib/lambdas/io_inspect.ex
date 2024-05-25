defmodule Github.Lambdas.IOInspect do
  def print(%{"value" => value}) do
    IO.inspect(inspect value)
    %{"value" => value}
  end
end
