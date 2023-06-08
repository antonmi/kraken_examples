defmodule Github.Helpers do
  def sleep(args, _arg) do
    IO.inspect("sleeping ...")
    Process.sleep(1)
    args
  end

  def check(args, _arg) do
    IO.inspect(args, label: "check")
    args
  end
end
