defmodule DaftScraperTest do
  use ExUnit.Case
  doctest DaftScraper

  test "greets the world" do
    assert DaftScraper.hello() == :world
  end
end
