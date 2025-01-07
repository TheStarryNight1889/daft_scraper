defmodule DaftScraper.DaftRentalSpider do
  use GenServer
  require Poison
  require Logger

  # this is the number of houses we want to scrape in total
  @max_items 2170
  # this value doesnt effect anything but the interface requires it
  @items_per_page 20
  @start_point 200

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    rental_info = get_rental_info(@start_point, @items_per_page, @max_items)
    Process.sleep(5000)
    {:ok, rental_info}
  end

  defp get_rental_info(from, _page_size, max) when from >= max do
    []
  end

  defp get_rental_info(from, page_size, max) do
    Process.sleep(4000)
    Logger.info("Fetching listings from #{from} to #{from + page_size}")
    url = "https://www.daft.ie/property-for-rent/ireland?pageSize=#{page_size}&from=#{from}"

    {:ok, rental_info} =
      fetch_page(url)
      |> parse_info_from_page()

    DaftScraper.FileWriter.write(rental_info)
    get_rental_info(from + page_size, page_size, max)
  end

  defp fetch_page(url) do
    case Req.get(url) do
      {:ok, response} ->
        response

      {:error, error} ->
        Logger.error("Error fetching page: #{inspect(error)}")
    end
  end

  defp parse_info_from_page(response) do
    html = response.body

    case Floki.parse_document(html) do
      {:ok, document} ->
        script_tag = Floki.find(document, "script#__NEXT_DATA__")
        # Get the text content (third element of the tuple)
        rental_info = elem(hd(script_tag), 2) |> hd()

        case Poison.decode(rental_info) do
          {:ok, json_data} ->
            cleaned_data =
              json_data["props"]["pageProps"]["listings"]
              |> clean_rental_info_obj()

            {:ok, cleaned_data}

          {:error, error} ->
            Logger.error("Error parsing JSON: #{inspect(error)}")
            {:error, :json_parse_failed}
        end

      {:error, error} ->
        Logger.error("Error parsing document: #{inspect(error)}")
    end
  end

  defp clean_rental_info_obj(rental_info) do
    Enum.map(rental_info, fn rental ->
      rental_listing = rental["listing"]
      seller_info = rental_listing["seller"]

      %{
        title: rental_listing["title"],
        seller: %{
          sellerId: seller_info["sellerId"],
          sellerType: seller_info["sellerType"],
          name: seller_info["name"],
          branch: seller_info["branch"]
        },
        saleType: rental_listing["saleType"],
        propertyType: rental_listing["propertyType"],
        price: rental_listing["price"] |> clean_numeric_string(),
        beds: rental_listing["numBedrooms"] |> clean_numeric_string(),
        baths: rental_listing["numBathrooms"] |> clean_numeric_string(),
        id: rental_listing["id"],
        ber: rental_listing["ber"]
      }
    end)
  end

  defp clean_numeric_string(nil), do: nil

  defp clean_numeric_string(priceStr) do
    String.replace(priceStr, ~r/\D/, "") |> String.to_integer()
  end
end
