defmodule PollsAppWeb.VotesPage do
  use PollsAppWeb, :surface_live_view

  alias PollsApp.{Polls, Votes}
  alias Moon.Design.{Button, Progress}
  alias Moon.Icon

  on_mount {PollsAppWeb.UserAuth, :mount_current_user}
  on_mount {PollsAppWeb.UserAuth, :ensure_authenticated}

  def mount(params, _session, socket) do
    id = Map.get(params, "id")

    poll = Polls.get_poll!(id)

    selected_option =
      Votes.get_user_vote_for_poll(socket.assigns.current_user.id, String.to_integer(id))

    if connected?(socket) do
      Phoenix.PubSub.subscribe(PollsApp.PubSub, "vote")
      Phoenix.PubSub.subscribe(PollsApp.PubSub, "polls")
    end

    {:ok,
     assign(socket,
       poll: poll,
       selected_option: selected_option,
       votes_ranking: Polls.votes_distribution(poll.id)
     )}
  end

  def render(assigns) do
    ~F"""
    <div class="flex w-full px-28">
      <div class="flex flex-col justify-start items-center w-full">
        <div class="w-full bg-white rounded-lg shadow border p-8">
          <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">#{@poll.id} {@poll.name}</h2>
          <h2 class="text-md text-center text-gray-800 mb-6">Click on the option you'd like to vote for</h2>
            {#for option <- @poll.options}
              <div class="flex items-center mb-6">
                <Button
                  on_click="vote"
                  values={[option: option]}
                  class="w-full text-white font-bold py-3 px-4 rounded-lg bg-gray-400 hover:bg-gray-500"
                >
                  {option}
                </Button>
                <Icon
                  name={"#{if @selected_option == "You voted for: #{option}", do: "generic_check_rounded", else: ""}"}
                  class="text-moon-48 text-roshi"
                />
              </div>
            {/for}
          <div class="mt-6 text-center">
            <p class="text-lg text-gray-700">
              <span class="text-grey-500">{@selected_option}</span>
            </p>
          </div>
          <div class="p-4 border-beerus flex justify-between pt-8">
            <Button variant="outline" on_click="exit_poll">Back to Polls</Button>
            {#if @selected_option == "You didn't vote yet"}
              <Button class="bg-popo hover:bg-neutral-700 ml-4" on_click="retract_vote" disabled="true">Retract Vote</Button>
            {#else}
              <Button class="bg-popo hover:bg-neutral-700 ml-4" on_click="retract_vote">Retract Vote</Button>
            {/if}
          </div>
        </div>
      </div>
      <div class="flex flex-col justify-start items-center w-full">
        <div
          class="max-w-2xl w-full bg-white rounded-lg shadow border border-grey-400 p-8"
        >
          <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">Result of Poll</h2>
          <div class="grid grid-cols-1 gap-4">
            {#for {option, votes_count, percentage} <- @votes_ranking}
              <div class="flex flex-col">
                <Progress value={percentage} class="mt-16">
                  <Progress.Pin class="mt-4" />
                </Progress>
                <div class="ml-4 text-gray-600 flex gap-5 justify-center">
                  <p class="text-base mr-4 font-medium">
                    {option}:
                  </p>
                  <p class="text-base mr-4 font-medium">
                    {votes_count} votes
                  </p>
                </div>
              </div>
            {/for}
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_info({:new_vote, _new_poll}, socket) do
    votes_ranking =
      socket.assigns.poll.id
      |> Polls.votes_distribution()

    {:noreply, assign(socket, votes_ranking: votes_ranking)}
  end

  def handle_info({:new_poll, "delete"}, socket) do
    updated_polls = Polls.list_all_polls_with_authors()

    {:noreply,
     assign(socket, all_polls: updated_polls)
     |> push_redirect(to: "/polls")}
  end

  def handle_event("vote", %{"option" => option}, socket) do
    poll_id = socket.assigns.poll.id
    user_id = socket.assigns.current_user.id

    case Votes.create_vote(%{poll_id: poll_id, user_id: user_id, option: option}) do
      {:ok, _vote} ->
        Phoenix.PubSub.broadcast(PollsApp.PubSub, "vote", {:new_vote, ""})

        {:noreply,
         assign(socket,
           selected_option: "You voted for: #{option}",
           votes_ranking: Polls.votes_distribution(poll_id)
         )}

      {:error, _} ->
          socket = put_flash(socket, :error, "You have already voted in this poll.")
          {:noreply, socket}
    end
  end

  def handle_event("exit_poll", _params, socket) do
    {:noreply, push_redirect(socket, to: "/polls")}
  end

  def handle_event("retract_vote", _params, socket) do
    socket.assigns.current_user.id
    |> Votes.delete_vote(socket.assigns.poll.id)

    Phoenix.PubSub.broadcast(PollsApp.PubSub, "vote", {:new_vote, ""})

    {:noreply,
     assign(socket,
       selected_option: "You didn't vote yet",
       votes_ranking: Polls.votes_distribution(socket.assigns.poll.id)
     )}
  end
end
