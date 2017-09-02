defmodule PhotoBoothUi.FakeVideoStreamer do
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    frames =
      "video_lobby"
      |> File.read!()
      |> String.split("\n")
      |> Enum.reject(fn(s) -> String.length(s) == 0 end)

    send(self(), :send_frame)
    {:ok, frames}
  end

  def handle_info(:send_frame, [frame | frames]) do
    msg = %{base64_data: frame}
    PhotoBoothUiWeb.Endpoint.broadcast("video:lobby", "next_frame", msg)
    Process.send_after(self(), :send_frame, 100)
    {:noreply, frames ++ [frame]}
  end
end
