defmodule SentinelWeb.SessionLive.RegistrationTest do
  use SentinelWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sentinel.AccountsFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/registration")

      assert html =~ "Create an account"
      assert html =~ "Login"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/registration")
        |> follow_redirect(conn, "/monitors")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/registration")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "short"})

      assert result =~ "Create an account"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 8 character"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/registration")

      email = unique_user_email()
      form = form(lv, "#registration_form", user: valid_user_attributes(email: email))
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/monitors"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/monitors")
      response = html_response(conn, 200)
      assert response =~ "Monitors"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/registration")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/registration")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Login")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/log_in")

      assert login_html =~ "Log in"
    end
  end
end
