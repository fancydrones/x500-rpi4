defmodule CompanionWeb.ConfigLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    configs = Companion.K8sManager.get_configs()

    if connected?(socket) do
      :ok
    end

    socket =
      socket
      |> assign(configs: configs)
    {:ok, socket}
  end

  @impl true
  def handle_event("get_config", _, socket) do
    Logger.info("Clicked restart Get Config")

    configs = Companion.K8sManager.get_configs()

    socket =
      socket
      |> assign(configs: configs)

    {:noreply, socket}
  end

  def handle_event("save_config", %{"config" => update}, socket) do
    {key, value} =
      update
      |> Map.to_list
      |> List.first

    Logger.info("Key: #{key} -- Value: #{value}")

    Companion.K8sManager.update_config(key, value)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="phx-hero">
      <h1>Update Config:</h1>
      <button phx-click="get_config">Refresh Config</button>
      <%= if length(@configs) > 0 do %>
        <h2>All configs</h2>
        <%= for config <- @configs do %>
          <.form let={f} for={:config} phx-submit="save_config">
            <%= label f, config.key %>
            <%= textarea f, config.key, value: config.value %>
            <%= submit "Save" %>
          </.form>
        <% end %>
      <% else %>
        <h2>No configs found</h2>
      <% end %>
    </section>
    """
  end
end
