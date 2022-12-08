defmodule ExWorkerbook.Plugins.Unwrap do
  @moduledoc """

  ## Examples

    # unwrap a list into list of tuples
    iex> ExWorkerbook.Plugins.Unwrap.call([:a, :b])
    [{:value, nil, :a, []}, {:value, nil, :b, []}]

    # unwrap a map key value pairs into a list of key, value tuples
    iex> ExWorkerbook.Plugins.Unwrap.call(%{"a" => 1, "b" => 2})
    [
      [{:key, "a", "a", []}, {:value, "a", 1, []}],
      [{:key, "b", "b", []}, {:value, "b", 2, []}]
    ]

    # unwrap and transform list values
    iex> ExWorkerbook.Plugins.Unwrap.call([1, 2], with: fn val -> val + 1 end)
    [{:value, nil, 2, []}, {:value, nil, 3, []}]

    # unwrap and assign an id to list values
    iex> ExWorkerbook.Plugins.Unwrap.call([:a, :b], with: fn val -> {"alphabet", val} end)
    [{:value, "alphabet", :a, []}, {:value, "alphabet", :b, []}]

    # unwrap and transform map keys and values
    iex> ExWorkerbook.Plugins.Unwrap.call(%{a: 1, b: 2}, with: fn {k, v} -> {"inc_" <> to_string(k), v + 1} end)
    [
      [{:key, :a, "inc_a", []}, {:value, :a, 2, []}],
      [{:key, :b, "inc_b", []}, {:value, :b, 3, []}]
    ]
  """

  @behaviour ExWorkerbook.Adapter.Plugin

  @impl ExWorkerbook.Adapter.Plugin
  def call(enum, opts \\ []) when is_list(enum) or is_map(enum) do
    fun = Keyword.get(opts, :with, &Function.identity/1)
    enum |> Enum.reduce([], &unwrap_enumerable(fun, &1, &2))
  end

  defp unwrap_enumerable(fun, {key, val}, acc) do
    {label, val} = fun.({key, val})

    row_key = row(:key, key, label)
    row_val = row(:value, key, val)

    acc ++ row_key ++ row_val
  end

  defp unwrap_enumerable(fun, val, acc) do
    {id, val} =
      case fun.(val) do
        {id, val} -> {id, val}
        val -> {nil, val}
      end

    acc ++ row(:value, id, val)
  end

  defp row(type, id, val), do: [{type, id, val, []}]
end
