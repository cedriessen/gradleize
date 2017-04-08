defmodule Gradleize.Shell do
  @moduledoc false

  def error(text) do
    text |> coloured([:red, :bright])
  end

  def info(text) do
    text |> coloured([:blue, :bright])
  end

  def text(text) do
    IO.puts text
  end

  def warn(text) do
    text |> coloured([:yellow, :bright])
  end

  def coloured(text, colour) do
    [colour, text]
    |> ansi
  end

  def ansi(io_list) do
    io_list
    |> IO.ANSI.format(true)
    |> IO.puts
  end
end
