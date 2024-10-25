### <h1 align="center" style="font-size: 70px"><strong>Polls App</strong></h1>
Polls App is a real-time polling application built with Elixir and Phoenix LiveView. Users can create, vote on, and manage polls easily. The application is designed to be user-friendly, allowing registered users to interact with polls effortlessly.

You can visit the deployed version of the application at [Polls App Deployment](https://polls-app-task.fly.dev/).

### **Features**

- Create Polls: Registered users can create new polls and set options for voting.
- Vote on Polls: Users can vote on existing polls.
- View Poll Results: Users can see the distribution of votes for each poll in real-time.
- Delete Polls: Authors of polls can delete their polls when necessary.
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

