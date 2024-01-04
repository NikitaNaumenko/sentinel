defmodule SentinelWeb.MonitorLiveTest do
  use SentinelWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sentinel.ChecksFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_monitor(_) do
    monitor = monitor_fixture()
    %{monitor: monitor}
  end

  describe "Index" do
    setup [:create_monitor]

    test "lists all monitors", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/monitors")

      assert html =~ "Listing Monitors"
    end

    test "saves new monitor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/monitors")

      assert index_live |> element("a", "New Monitor") |> render_click() =~
               "New Monitor"

      assert_patch(index_live, ~p"/monitors/new")

      assert index_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#monitor-form", monitor: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/monitors")

      html = render(index_live)
      assert html =~ "Monitor created successfully"
    end

    test "updates monitor in listing", %{conn: conn, monitor: monitor} do
      {:ok, index_live, _html} = live(conn, ~p"/monitors")

      assert index_live |> element("#monitors-#{monitor.id} a", "Edit") |> render_click() =~
               "Edit Monitor"

      assert_patch(index_live, ~p"/monitors/#{monitor}/edit")

      assert index_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#monitor-form", monitor: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/monitors")

      html = render(index_live)
      assert html =~ "Monitor updated successfully"
    end

    test "deletes monitor in listing", %{conn: conn, monitor: monitor} do
      {:ok, index_live, _html} = live(conn, ~p"/monitors")

      assert index_live |> element("#monitors-#{monitor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#monitors-#{monitor.id}")
    end
  end

  describe "Show" do
    setup [:create_monitor]

    test "displays monitor", %{conn: conn, monitor: monitor} do
      {:ok, _show_live, html} = live(conn, ~p"/monitors/#{monitor}")

      assert html =~ "Show Monitor"
    end

    test "updates monitor within modal", %{conn: conn, monitor: monitor} do
      {:ok, show_live, _html} = live(conn, ~p"/monitors/#{monitor}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Monitor"

      assert_patch(show_live, ~p"/monitors/#{monitor}/show/edit")

      assert show_live
             |> form("#monitor-form", monitor: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#monitor-form", monitor: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/monitors/#{monitor}")

      html = render(show_live)
      assert html =~ "Monitor updated successfully"
    end
  end
end
