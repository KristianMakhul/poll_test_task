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
      |> push_redirect(to: "/polls")
    }
  end

  def handle_event("vote", %{"option" => option}, socket) do
    poll_id = socket.assigns.poll.id
    user_id = socket.assigns.current_user.id

    existing_vote =
      Votes.get_user_vote_for_poll(user_id, poll_id)

    case existing_vote do
      "You didn't vote yet" ->
        Votes.create_vote(%{
          poll_id: poll_id,
          user_id: user_id,
          option: option
        })

        Phoenix.PubSub.broadcast(PollsApp.PubSub, "vote", {:new_vote, ""})

        {:noreply,
         assign(socket,
           selected_option: "You voted for: #{option}",
           votes_ranking: Polls.votes_distribution(poll_id)
         )}

      _ ->
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
