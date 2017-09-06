defmodule PhotoBoothUiWeb.VideoChannel do
  use PhotoBoothUiWeb, :channel

  @tweet_length 140
  @tweet_tags " #ElixirFriends #ElixirConf2017"
  @tweet_slice @tweet_length - String.length(@tweet_tags)

  def join("video:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (video:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("update_effect", %{"effect" => effect}, socket) do
    camera()
    |> GenServer.cast({:set_img_effect, effect})

    {:noreply, socket}
  end

  def handle_in("tweet", %{"img" => "data:image/png;base64," <> img, "msg" => msg}, socket) do
    tweet(msg, img)
    camera()
    |> GenServer.cast({:set_img_effect, "none"})
    {:reply, :ok, socket}
  end

  defp camera() do
    GenServer.whereis({:global, PhotoBooth.Camera})
  end

  def tweet(msg, img) do
    msg = String.slice(msg, 0, @tweet_slice) <> @tweet_tags
    img = Base.decode64!(img)
    ExTwitter.update_with_media(msg, img)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

end
