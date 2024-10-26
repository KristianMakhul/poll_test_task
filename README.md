### <h1 align="center" style="font-size: 70px"><strong>Polls App</strong></h1>
Polls App is a real-time polling application built with Elixir and Phoenix LiveView. Users can create, vote on, and manage polls easily. The application is designed to be user-friendly, allowing registered users to interact with polls effortlessly.

You can visit the deployed version of the application at [Polls App Deployment](https://polls-app-task.fly.dev/).

### **Features**

- Create Polls: Registered users can create new polls and set options for voting.
- Vote on Polls: Users can vote on existing polls.
- View Poll Results: Users can see the distribution of votes for each poll in real-time.
- Delete Polls: Authors of polls can delete their polls when necessary.

### <h2>How the App Works</h2>
To get started with Polls App, follow these simple steps:

1. **Register or Log In:**
To create or manage polls, you’ll need to register or log in first. This ensures that only authorized users can manage polls.

2. **Create or Participate in Polls:**
Once logged in, you can create a new poll by entering a question and providing the answer options that users will vote on.
Alternatively, if you want to join an existing poll, just click on the poll that interests you.

3. **Vote on a Poll:**
Choose the poll you’d like to vote on from the list of available polls.
Click on the option you want to vote for. Your vote will be instantly counted, and the results will update in real-time.
If you change your mind, you can retract your vote and select a different option instead.

4. **Delete Polls:** 
Only the creator of a poll has the authority to delete it, ensuring that users have control over their own polls.

### <h3>Design Decisions</h3>
**Progress Bar for Votes:** Next to each voting option, there’s a progress bar that visually represents how many votes each option has received. This makes it easy for users to instantly see the most popular options.

**Real-Time Updates:** Voting results update immediately for all users viewing the poll, thanks to Phoenix LiveView’s real-time functionality. This makes voting engaging and responsive.

**Separate Pages for Poll Listing and Voting:** Keeping the list of polls on one page and the voting process on a dedicated page makes the app more user-friendly and organized. Users can easily browse available polls without distractions and dive into the voting details only when they're ready to participate. 

### <h2>Installing / Getting started</h2>
**Prerequisites**

- Docker and Docker Compose installed on your machine.

**Running the Application**

Clone the Repository:
```
git clone https://github.com/KristianMakhul/poll_test_task.git
cd poll_test_task/
```

**Install Dependencies:**

`mix deps.get`

**Set up assets:**
```
mix assets.setup
mix assets.build
```
**Set up the database:**

`docker-compose up -d`

**Run database migrations and seeds:**

`mix ecto.reset`

**Start the Phoenix server:**
`mix phx.server`

Your application should now be running at [localhost:4000]( http://localhost:4000)

### <h2>Tests</h2>
To run the test suite, follow these steps:

1. **Set up the test database:**

```
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
```

2. **Run the tests:**

`mix test`

