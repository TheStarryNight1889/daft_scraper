defmodule DaftScraper.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DaftScraper.FileWriter, name: DaftScraper.FileWriter},
      {DaftScraper.DaftRentalSpider, name: DaftScraper.DaftRentalSpider}
    ]

    opts = [strategy: :one_for_one, name: DaftScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
