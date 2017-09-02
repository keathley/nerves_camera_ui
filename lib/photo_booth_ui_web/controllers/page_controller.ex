defmodule PhotoBoothUiWeb.PageController do
  use PhotoBoothUiWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
