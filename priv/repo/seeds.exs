{:ok, user1} = PollsApp.Accounts.register_user(%{username: "Ruth", password: "123"})
{:ok, user2} = PollsApp.Accounts.register_user(%{username: "Mia", password: "123"})
{:ok, user3} = PollsApp.Accounts.register_user(%{username: "Sean", password: "123"})
{:ok, user4} = PollsApp.Accounts.register_user(%{username: "Max", password: "123"})
{:ok, user5} = PollsApp.Accounts.register_user(%{username: "John", password: "123"})

{:ok, poll1} = PollsApp.Polls.seeds_poll(%{
  name: "What language do you prefer?",
  user_id: user1.id,
  options: ["Elixir", "Ruby", "Python", "JavaScript"]
})

{:ok, poll2} = PollsApp.Polls.seeds_poll(%{
  name: "What is your favorite type of cuisine?",
  user_id: user2.id,
  options: ["Italian", "Japanese", "Mexican", "Indian"]
})

{:ok, poll3} = PollsApp.Polls.seeds_poll(%{
  name: "What kind of movies do you like?",
  user_id: user1.id,
  options: ["Action", "Comedy", "Drama", "Horror"]
})


PollsApp.Votes.create_vote(%{poll_id: poll1.id, user_id: user1.id, option: "Elixir"})
PollsApp.Votes.create_vote(%{poll_id: poll1.id, user_id: user2.id, option: "Elixir"})
PollsApp.Votes.create_vote(%{poll_id: poll1.id, user_id: user3.id, option: "Ruby"})
PollsApp.Votes.create_vote(%{poll_id: poll1.id, user_id: user4.id, option: "Elixir"})
PollsApp.Votes.create_vote(%{poll_id: poll2.id, user_id: user4.id, option: "Japanese"})
PollsApp.Votes.create_vote(%{poll_id: poll2.id, user_id: user5.id, option: "Italian"})
PollsApp.Votes.create_vote(%{poll_id: poll3.id , user_id: user1.id, option: "Action"})
PollsApp.Votes.create_vote(%{poll_id: poll3.id, user_id: user2.id, option: "Comedy"})
PollsApp.Votes.create_vote(%{poll_id: poll3.id, user_id: user3.id, option: "Comedy"})
PollsApp.Votes.create_vote(%{poll_id: poll3.id, user_id: user4.id, option: "Horror"})
PollsApp.Votes.create_vote(%{poll_id: poll3.id, user_id: user5.id, option: "Comedy"})
