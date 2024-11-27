defmodule Sentinel.EscalationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sentinel.Escalations` context.
  """

  alias Sentinel.Escalations
  alias Sentinel.Escalations.Alert
  alias Sentinel.Escalations.Policy
  alias Sentinel.Escalations.Step
  alias Sentinel.Repo

  @doc """
  Generate a monitor.
  """
  def escalation_policy_fixture(attrs \\ %{}) do
    attrs =
      Map.merge(%{name: "Escalation Policy#{System.unique_integer()}"}, attrs)

    {:ok, escalation_policy} = Escalations.create_escalation_policy(attrs)
    escalation_policy
  end

  def escalation_step_attrs(attrs \\ %{}) do
    Map.merge(%{notify_after: 1}, attrs)
  end

  def escalation_alert_attrs(attrs \\ %{}) do
    Map.merge(%{alert_type: :email}, attrs)
  end
end
