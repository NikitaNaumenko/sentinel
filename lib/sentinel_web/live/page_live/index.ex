defmodule SentinelWeb.PageLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.StatusPages
  # alias Sentinel.StatusPages.Page

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :pages, StatusPages.list_pages())}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket |> assign(:page_title, "Listing Pages") |> assign(:page, nil)}
  end

  @impl true
  def handle_info({SentinelWeb.PageLive.FormComponent, {:saved, page}}, socket) do
    {:noreply, stream_insert(socket, :pages, page)}
  end
end
