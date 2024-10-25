defmodule PollsAppWeb.PollsPage do
  use PollsAppWeb, :surface_live_view

  alias PollsApp.{Polls, Poll}
  alias Moon.Design.{Button, Modal, Form}
  alias Moon.Design.Form.{Field, Input}

  on_mount {PollsAppWeb.UserAuth, :mount_current_user}
  on_mount {PollsAppWeb.UserAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PollsApp.PubSub, "polls")
      Phoenix.PubSub.subscribe(PollsApp.PubSub, "vote")
    end

    {:ok,
     assign(socket,
       all_polls: Polls.list_all_polls_with_authors(),
       poll_modal_open: false,
       form: to_form(Polls.poll_changeset()),
       poll_delete_open: false,
       poll: %{id: nil, name: nil},
       votes_distribution: Polls.polls_votes_distribution()
     )}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:new_vote, _new_poll}, socket) do
    {:noreply, assign(socket, votes_distribution: Polls.polls_votes_distribution())}
  end

  def handle_info({:new_poll, _new_poll}, socket) do
    updated_polls = Polls.list_all_polls_with_authors()
    {:noreply, assign(socket, all_polls: updated_polls, votes_distribution: Polls.polls_votes_distribution())}
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_poll_modal")
    {:noreply,assign(socket, poll_modal_open: true)}
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_poll_modal")
    {:noreply, assign(socket, poll_modal_open: false)}
  end

  def handle_event("open_delete_modal", %{"value" => id}, socket) do
    Modal.open("delete_poll_modal")
    {:noreply,assign(socket,poll_delete_open: true, poll: Polls.get_poll!(id))}
  end

  def handle_event("close_delete_modal", _, socket) do
    Modal.close("delete_poll_modal")
    {:noreply, assign(socket, poll_delete_open: false)}
  end

  def handle_event("validate", %{"poll" => poll_attrs}, socket) do
    options_array =
      Map.get(poll_attrs, "options", "")
      |> parse_options_input()

    poll_attrs = Map.put(poll_attrs, "options", options_array)

    form =
      Polls.poll_changeset(poll_attrs)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    Process.send_after(self(), :clear_flash, 3000)
    Modal.close("create_poll_modal")

    poll_params =
      poll_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.update("options", "", &parse_options_input/1)

    options_count = length(Map.get(poll_params, "options", []))

    if options_count < 2 do
      {:noreply,
       assign(socket,
         form: to_form(Polls.poll_changeset()),
         poll_modal_open: false
       )
       |> put_flash(:error, "Cannot create a poll with only one option.")}
    else
      case Polls.create_poll(poll_params) do
        {:ok, poll} ->
          Phoenix.PubSub.broadcast(PollsApp.PubSub, "polls", {:new_poll, poll})

          {:noreply,
           assign(
             socket,
             form: to_form(Polls.poll_changeset()),
             poll_modal_open: false,
             all_polls: Polls.list_all_polls_with_authors()
           )
           |> put_flash(:info, "Poll successfully created")}

        {:error, _changeset} ->
          {:noreply,
           assign(socket,
             form: to_form(Polls.poll_changeset()),
             poll_modal_open: false
           )
           |> put_flash(:error, "Post with same name already exists")}
      end
    end
  end

  def handle_event("confirm_delete_modal", %{"value" => id}, socket) do
    Process.send_after(self(), :clear_flash, 3000)
    Polls.delete_poll(%Poll{id: String.to_integer(id)})

    Phoenix.PubSub.broadcast(PollsApp.PubSub, "polls", {:new_poll, "delete"})

    Modal.close("delete_poll_modal")

    {:noreply,
     assign(
       socket,
       form: to_form(Polls.poll_changeset()),
       poll_delete_open: false,
       all_polls: Polls.list_all_polls_with_authors()
     ) |> put_flash(:info, "Poll was deleted")  |> push_redirect(to: "/polls")}
  end

  defp parse_options_input(nil), do: []

  defp parse_options_input(options) do
    options
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end
end
