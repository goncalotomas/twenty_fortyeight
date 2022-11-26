defmodule TwentyFortyeightWeb.TwentyFortyeightLive do
  use TwentyFortyeightWeb, :live_view

  alias TwentyFortyeight.Game

  @default_grid_size 4

  def render(assigns) do
    ~H"""
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="sm:flex sm:items-center">
          <div class="sm:flex-auto">
            <h1 class="text-xl font-semibold text-gray-900">2048</h1>
            <p class="mt-2 text-sm text-gray-700">
              <%= if @state == :started do %>
              Click the arrows to move and stack numbers until you get to 2048!
              <% end %>
              <%= if @state == :won do %>
              You actually got to 2048, impressive! You win 🥳🎉
              <% end %>
              <%= if @state == :lost do %>
              You lost! Click the New Game button to continue playing! 🥺
              <% end %>
            </p>
          </div>
          <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
            <button type="button" phx-click="new_game" class="inline-flex items-center justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:w-auto">New game</button>
          </div>
        </div>
        <div class="mt-8 flex flex-col">
          <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div class="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
              <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                <table class="min-w-full divide-y divide-gray-300 table-auto">
                  <tbody class="divide-y divide-gray-200 bg-white">
                    <%= for line <- @grid do %>
                    <tr class="divide-x divide-gray-200">
                      <%= for index <- 0..@grid_size-1 do %>
                        <td class="whitespace-nowrap p-4 text-sm font-medium text-gray-900"><%= Enum.at(line, index) %></td>
                      <% end %>
                    </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="py-7 grid grid-cols-4 gap-3 content-center">

        <button type="button" phx-click="swipe_left" phx-window-keyup="swipe_left" phx-key="ArrowLeft" disabled={@state != :started} class="relative inline-flex items-center rounded-l-md border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
          <span class="sr-only">Left</span>
          <!-- Heroicon name: mini/chevron-left -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5L8.25 12l7.5-7.5" />
          </svg>
        </button>
        <button type="button" phx-click="swipe_up" phx-window-keyup="swipe_up" phx-key="ArrowUp" disabled={@state != :started} class="relative -ml-px inline-flex items-center border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
          <span class="sr-only">Up</span>
          <!-- Heroicon name: mini/chevron-right -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 15.75l7.5-7.5 7.5 7.5" />
          </svg>
        </button>
        <button type="button" phx-click="swipe_down" phx-window-keyup="swipe_down" phx-key="ArrowDown" disabled={@state != :started} class="relative -ml-px inline-flex items-center border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
          <span class="sr-only">Down</span>
          <!-- Heroicon name: mini/chevron-down -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
          </svg>
        </button>
        <button type="button" phx-click="swipe_right" phx-window-keyup="swipe_right" phx-key="ArrowRight" disabled={@state != :started} class="relative -ml-px inline-flex items-center rounded-r-md border border-gray-300 bg-white px-2 py-2 text-sm font-medium text-gray-500 hover:bg-gray-50 focus:z-10 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500">
          <span class="sr-only">Right</span>
          <!-- Heroicon name: mini/chevron-right -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
          </svg>
        </button>
      </div>

    """
  end

  def mount(_params, _session, socket) do
    {state, grid} = game = Game.new(@default_grid_size)

    {
      :ok,
      socket
      |> assign(:grid, grid)
      |> assign(:state, state)
      |> assign(:game, game)
      |> assign(:grid_size, @default_grid_size)
    }
  end

  def handle_event("new_game", _, socket) do
    {state, grid} = game = Game.new(4)

    {
      :noreply,
      socket
      |> assign(:grid, grid)
      |> assign(:game, game)
      |> assign(:state, state)
    }
  end

  def handle_event("swipe_up", %{"key" => "ArrowUp"}, socket) do
    do_swipe(socket, :up)
  end

  def handle_event("swipe_up", _, socket) do
    do_swipe(socket, :up)
  end

  def handle_event("swipe_down", %{"key" => "ArrowDown"}, socket) do
    do_swipe(socket, :down)
  end

  def handle_event("swipe_down", _, socket) do
    do_swipe(socket, :down)
  end

  def handle_event("swipe_left", %{"key" => "ArrowLeft"}, socket) do
    do_swipe(socket, :left)
  end

  def handle_event("swipe_left", _, socket) do
    do_swipe(socket, :left)
  end

  def handle_event("swipe_right", %{"key" => "ArrowRight"}, socket) do
    do_swipe(socket, :right)
  end

  def handle_event("swipe_right", _, socket) do
    do_swipe(socket, :right)
  end

  defp do_swipe(socket, direction) do
    {state, grid} =
      game =
      case direction do
        :up -> Game.swipe_up(socket.assigns.game)
        :down -> Game.swipe_down(socket.assigns.game)
        :left -> Game.swipe_left(socket.assigns.game)
        :right -> Game.swipe_right(socket.assigns.game)
      end

    {
      :noreply,
      socket
      |> assign(:grid, grid)
      |> assign(:state, state)
      |> assign(:game, game)
    }
  end
end
