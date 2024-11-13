defmodule PollsAppWeb.WelcomePage do
  use PollsAppWeb, :surface_live_view
  alias Moon.Design.Button

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~F"""
    <div class="flex flex-col items-center justify-center mx-4 md:mx-0 font-oswald">
      <div class="bg-white rounded-lg border border-grey-400  p-8 text-center">
        <h1 class="text-4xl font-bold text-gray-800 mb-4">Welcome to the Polling Application!</h1>
        <p class="text-lg text-gray-600 mb-4">
          Create and participate in polls effortlessly. Share your opinions and engage with the community!
        </p>
        <p class="text-md text-gray-500 mb-6">
          Please note: To cast your vote, you'll need to register or log in.
        </p>
        <div class="flex justify-center space-x-4">
          <.link navigate={~p"/polls"}>
            <Button variant="outline">View Existing Polls</Button>
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
