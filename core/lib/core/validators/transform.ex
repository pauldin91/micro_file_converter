defmodule Core.Validators.Transform do
  @transformations Core.Transforms.transformations()

  @spec validate(map(),atom() | String.t()) ::
          {:ok, map()} | {:error, map()}
  def validate(props,transform) when is_binary(transform) do
    validate(props,String.to_existing_atom(transform))
  rescue
    ArgumentError -> {:error, %{transform: "Unknown transform"}}
  end

  def validate(props,transform) when is_atom(transform) do
    with {:ok, spec} <- fetch_transform(transform),
         {:ok, props} <- normalize_props(props),
         {:ok, validated} <- validate_props(spec.props, props) do
      {:ok, validated}
    end
  end

  ## -------- helpers --------

  defp fetch_transform(transform) do
    case Map.fetch(@transformations, transform) do
      {:ok, spec} -> {:ok, spec}
      :error -> {:error, %{transform: "Unknown transform"}}
    end
  end

  defp normalize_props(props) do
    {:ok,
     Map.new(props, fn {k, v} ->
       {to_string(k), v}
     end)}
  end

  defp validate_props(specs, props) do
    allowed_keys = Enum.map(specs, & &1.key)

    errors =
      props
      |> Map.keys()
      |> Enum.reject(&(&1 in allowed_keys))
      |> Enum.map(&{&1, "is not allowed"})
      |> Map.new()

    if errors != %{} do
      {:error, errors}
    else
      do_validate_props(specs, props)
    end
  end

  defp do_validate_props(specs, props) do
    specs
    |> Enum.reduce({%{}, %{}}, fn spec, {ok, errors} ->
      key = spec.key
      value = Map.get(props, key, spec.default)

      case validate_prop(value, spec) do
        {:ok, v} -> {Map.put(ok, key, v), errors}
        {:error, err} -> {ok, Map.put(errors, key, err)}
      end
    end)
    |> case do
      {validated, %{}} -> {:ok, validated}
      {_, errors} -> {:error, errors}
    end
  end

  ## -------- per-prop validation --------

  defp validate_prop(value, %{type: :number} = spec) do
    with {:ok, number} <- cast_number(value),
         :ok <- check_min(number, spec),
         :ok <- check_max(number, spec) do
      {:ok, number}
    end
  end

  defp validate_prop(value, %{selection: allowed}) do
    value = to_string(value)

    if value in allowed do
      {:ok, value}
    else
      {:error, "must be one of #{Enum.join(allowed, ", ")}"}
    end
  end

  defp validate_prop(value, %{type: :text}) do
    {:ok, to_string(value)}
  end

  ## -------- checks --------

  defp cast_number(v) when is_number(v), do: {:ok, v}

  defp cast_number(v) when is_binary(v) do
    case Float.parse(v) do
      {n, ""} -> {:ok, n}
      _ -> {:error, "is not a number"}
    end
  end

  defp cast_number(_), do: {:error, "is not a number"}

  defp check_min(value, %{min: min}) when value < min,
    do: {:error, "must be ≥ #{min}"}

  defp check_min(_, _), do: :ok

  defp check_max(value, %{max: max}) when value > max,
    do: {:error, "must be ≤ #{max}"}

  defp check_max(_, _), do: :ok
end
