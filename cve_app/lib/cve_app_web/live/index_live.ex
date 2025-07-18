defmodule CveAppWeb.IndexLive do
  use CveAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
