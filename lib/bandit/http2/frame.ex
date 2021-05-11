defmodule Bandit.HTTP2.Frame do
  alias Bandit.HTTP2.Frame

  require Logger

  def parse(
        <<length::24, type::8, flags::binary-size(1), _reserved::1, stream::31,
          payload::binary-size(length), rest::binary>>
      ) do
    type
    |> case do
      0x04 -> Frame.Setting.build(flags, stream, payload)
      unknown -> handle_unknown_frame(unknown, flags, stream, payload)
    end
    |> case do
      {:ok, frame} -> {:ok, frame, rest}
      {:error, stream, code, reason} -> {:error, stream, code, reason}
    end
  end

  def parse(msg) do
    {:more, msg}
  end

  defp handle_unknown_frame(type, flags, stream, payload) do
    "Unknown frame (t: #{type} f: #{inspect(flags)} s: #{stream} p: #{inspect(payload)})"
    |> Logger.warn()

    {:ok, nil}
  end
end
