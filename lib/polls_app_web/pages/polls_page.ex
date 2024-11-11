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

  def render(assigns) do
    ~F"""
    <div class="min-h-screen p-6">
      <div class=" mx-auto bg-white rounded-lg p-8">
        <div class="flex justify-center items-center">
          <h2 class="text-2xl font-bold text-center mb-6">Select a Poll</h2>
          <span class="text-2xl font-bold text-center mb-6 ml-4">or</span>
          <Button class="bg-popo hover:bg-neutral-700 ml-4 mb-6" on_click="open_create_modal">Create New Poll</Button>
        </div>
        <div class="flex flex-col justify-center gap-6">
          {#for {poll_id, poll_name, author_name} <- Enum.reverse(@all_polls)}
            <div class="flex flex-col w-full bg-white border border-gray-400 rounded-lg shadow">
              <.link navigate={~p"/polls/#{poll_id}"}>
                <div class="p-6 flex flex-col justify-between">
                  <div>
                    <h3 class="text-xl font-semibold">{poll_name}</h3>
                    <p class="mt-2 text-gray-600">Click to view and vote!</p>
                  </div>
                  <p class="text-gray-800 text-lg font-medium mt-4">Author: {author_name}</p>
                </div>
              </.link>
              <div class="p-4 border-t border-gray-400">
                <h4 class="text-lg font-semibold">Votes Distribution:</h4>
                <ul class="mt-2 space-y-1">
                  {#for {option_name, votes_count, percentage} <- Map.get(@votes_distribution, poll_id, [])}
                    <li>
                      <p class="text-gray-700">{option_name}: {votes_count} votes ({percentage |> Float.round(2) |> to_string()}%)</p>
                    </li>
                  {/for}
                </ul>
              </div>
              <div class="p-4 border-t border-gray-400 flex justify-end">
                {#if @current_user && @current_user.username == author_name}
                  <Button on_click="open_delete_modal" variant="outline" value={poll_id}>Delete Poll</Button>
                {#else}
                  <Button on_click="open_delete_modal" variant="outline" value={poll_id} disabled>Delete Poll</Button>
                {/if}
              </div>
            </div>
          {/for}
        </div>
      </div>
    </div>

    <Modal id="create_poll_modal" is_open={@poll_modal_open}>
      <Modal.Backdrop />
      <Modal.Panel>
        <div class="p-4  border-beerus">
          <h3 class="text-moon-18 text-center text-bulma font-medium border-b-2 pb-4">
            Create new Poll
          </h3>
          <br>
          <div class="text-left border-b-2 pb-4">
            <Form for={@form} change="validate" submit="save">
              <Field field={:name} class="p-4" label="Poll name">
                <Input placeholder="Poll name" />
              </Field>
              <Field field={:options} class="p-4" label="Poll options (comma separated)">
                <Input placeholder="Enter options separated by commas" />
              </Field>
              <div class="p-4 border-beerus flex justify-end">
                <Button on_click="close_create_modal" variant="outline">Discard</Button>
                <Button type="submit" class="bg-popo hover:bg-zeno ml-4">Create</Button>
              </div>
            </Form>
          </div>
        </div>
      </Modal.Panel>
    </Modal>

    <Modal id="delete_poll_modal" is_open={@poll_delete_open} :if={@poll_delete_open}>
      <Modal.Backdrop />
      <Modal.Panel>
        <div class="p-4  border-beerus">
          <h3 class="text-moon-18 text-center text-bulma font-medium border-b-2 pb-4">
            Are you sure you want to delete role: {@poll.name} ?
          </h3>
          <br>
          <div class="text-left border-b-2 pb-4">
            id: {@poll.id}
            <br>
            Poll name: {@poll.name}
          </div>
        </div>
        <div class="p-4 border-beerus flex justify-end">
          <Button on_click="close_delete_modal" variant="outline">Discard</Button>
          <Button on_click="confirm_delete_modal" value={@poll.id} class="bg-popo hover:bg-zeno ml-4">Confirm</Button>
        </div>
      </Modal.Panel>
    </Modal>
    """
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info({:new_vote, _new_poll}, socket) do
    {:noreply, assign(socket, votes_distribution: Polls.polls_votes_distribution())}
  end

  def handle_info({:new_poll, _new_poll}, socket) do
    updated_polls = Polls.list_all_polls_with_authors()

    {:noreply,
     assign(socket,
       all_polls: updated_polls,
       votes_distribution: Polls.polls_votes_distribution()
     )}
  end

  def handle_event("open_create_modal", _, socket) do
    Modal.open("create_poll_modal")
    {:noreply, assign(socket, poll_modal_open: true)}
  end

  def handle_event("close_create_modal", _, socket) do
    Modal.close("create_poll_modal")
    {:noreply, assign(socket, poll_modal_open: false)}
  end

  def handle_event("open_delete_modal", %{"value" => id}, socket) do
    Modal.open("delete_poll_modal")
    {:noreply, assign(socket, poll_delete_open: true, poll: Polls.get_poll!(id))}
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
           |> put_flash(:error, "Post with same name already exists or you have duplicated options")}
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
     )
     |> put_flash(:info, "Poll was deleted")
     |> push_redirect(to: "/polls")}
  end

  defp parse_options_input(nil), do: []

  defp parse_options_input(options) do
    options
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end
end
