defmodule SentinelWeb.MonitorLive.Index do
  @moduledoc false
  use SentinelWeb, :live_view

  alias Sentinel.Monitors
  alias Sentinel.Monitors.Monitor
  alias Sentinel.Monitors.MonitorPolicy
  alias SentinelWeb.MonitorLive.MonitorComponent

  on_mount({AuthorizeHook, policy: MonitorPolicy})
  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    Monitors.subscribe("monitors-#{socket.assigns.current_user.account_id}")
    monitors = Monitors.list_monitors(socket.assigns.current_account.id)
    monitors_count = Enum.count(monitors)

    socket =
      socket
      |> assign(:page_title, "Listing Monitors")
      |> assign(:monitor, nil)
      |> stream(:monitors, monitors)
      |> assign(:monitors_total_count, monitors_count)
      |> allow_upload(:monitors,
        accept: :any,
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def terminate(_reason, socket) do
    Monitors.unsubscribe("monitors-#{socket.assigns.current_user.account_id}")
  end

  @impl true
  def handle_info({SentinelWeb.MonitorLive.FormComponent, {:saved, monitor}}, socket) do
    {:noreply, stream_insert(socket, :monitors, monitor)}
  end

  def handle_info({:msg, monitor}, socket) do
    {:noreply, stream_insert(socket, :monitors, monitor)}
  end

  def handle_info({:process_monitors, dest}, socket) do
    {:ok, _monitors} = Monitors.create_monitors_from_file(dest, socket.assigns.current_account.id)

    socket =
      socket
      |> put_flash(:success, dgettext("monitors", "Monitors created successfully"))
      |> push_navigate(to: ~p"/monitors")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    monitor = Monitors.get_monitor!(id)
    {:ok, _} = Monitors.delete_monitor(monitor)

    {:noreply, stream_delete(socket, :monitors, monitor)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :monitors, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    consume_uploaded_entries(socket, :monitors, fn %{path: path} = meta, entry ->
      extname = Path.extname(entry.client_name)

      dest = Path.join([:code.priv_dir(:sentinel), "uploads", Path.basename(path) <> extname])
      # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
      # IO.inspect(entry)
      File.cp!(path, dest)
      send(self(), {:process_monitors, dest})
    end)

    {:noreply, put_flash(socket, :info, dgettext("monitors", "Creating monitors from file..."))}
  end

  # defp error_to_string(:too_large), do: "Too large"
  # defp error_to_string(:too_many_files), do: "You have selected too many files"
  # defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  #
  defp handle_progress(:monitors, entry, socket) do
    if entry.done? do
      {:noreply, put_flash(socket, :info, dgettext("monitors", "File is uploaded"))}
    else
      {:noreply, socket}
    end
  end
end
