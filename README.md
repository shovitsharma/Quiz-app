# Live Quiz Application

A real-time, interactive quiz platform built with a Flutter frontend and a Node.js backend. This application allows hosts to create quizzes and run live game sessions where players can join and compete on their mobile devices.

## Features

### Host Features

  * **Secure Authentication:** Hosts can sign up and log in securely with JWT-based authentication.
  * **Full Quiz Editor:** Create, review, edit, and delete questions in a user-friendly editor.
  * **Host Live Sessions:** Start a real-time quiz session for any created quiz.
  * **Real-time Lobby:** View players as they join the game lobby in real-time.
  * **Game Control:** (Functionality Ready) Control the flow of the game by starting the quiz and advancing to the next question.

### Player Features

  * **Join with Code:** Easily join a game using a unique session code.
  * **Real-time Gameplay:** Receive questions and submit answers in real-time.
  * **Live Feedback:** Get instant feedback on whether an answer was correct.
  * **Live Lobby & Leaderboard:** See other players in the lobby and view a full-screen, ranked leaderboard at the end of the quiz.

-----

## Tech Stack

  * **Frontend (Mobile App):**

      * **Flutter & Dart:** For creating a cross-platform mobile application.
      * **`socket_io_client`:** For real-time communication with the backend.
      * **`http`:** For handling REST API requests (authentication, quiz management).
      * **`flutter_secure_storage`:** For securely persisting the host's login token.

  * **Backend (Server):**

      * **Node.js & Express.js:** For building the REST API and handling server logic.
      * **Socket.IO:** For enabling real-time, bidirectional communication during live quizzes.
      * **MongoDB & Mongoose:** As the database for storing users, quizzes, and session data.
      * **JSON Web Tokens (JWT):** For securing host-only API endpoints.
      * **bcrypt.js:** For hashing user passwords.

-----

## Application Architecture

The application is split into two main parts: the **Flutter App** and the **Node.js Server**.

1.  **REST API (`/api`):** Used for actions that are not real-time. This includes user signup/login and creating/fetching quiz data. The Flutter app sends standard HTTP requests to these endpoints.
2.  **WebSocket Server (`/live`):** Used for all live gameplay events. The Flutter app opens a persistent Socket.IO connection to this path to join lobbies, receive questions, and submit answers in real-time.

-----

## Setup and Installation

To run this project locally, you will need to set up both the backend server and the frontend Flutter app.

### Prerequisites

  * [Node.js](https://nodejs.org/) (v16 or later)
  * [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.0 or later)
  * [MongoDB](https://www.mongodb.com/try/download/community) installed and running locally, or a connection string from MongoDB Atlas.

### 1\. Backend Setup

```bash
# 1. Navigate to your backend project folder
cd /path/to/your/backend

# 2. Install dependencies
npm install

# 3. Create a .env file in the backend root and add the following variables
# (replace with your own values)
```

Create a file named `.env` in the root of the backend folder:

```.env
# The port the server will run on
PORT=4000

# Your connection string for MongoDB
MONGO_URI=mongodb://localhost:27017/quizApp

# A strong, secret key for signing JWTs
JWT_SECRET=this_is_a_very_strong_secret_key
```

```bash
# 4. Start the server
npm start

# The server should now be running on http://localhost:4000
```

### 2\. Frontend (Flutter App) Setup

```bash
# 1. Navigate to your flutter project folder
cd /path/to/your/flutter_app

# 2. Get dependencies
flutter pub get

# 3. Configure the server URL
# Open the file lib/config/app_config.dart and set the baseUrl
# to your computer's local Wi-Fi IP address.
```

Open the file **`lib/config/app_config.dart`** and update the IP:

```dart
class AppConfig {
  // For testing with a physical device, use your computer's local IP
  static const String baseUrl = "http://192.168.1.15:4000"; // Example
}
```

```bash
# 4. Run the app on your connected device or emulator
flutter run
```

-----

\<details\>
\<summary\>\<strong\>API Endpoints\</strong\>\</summary\>

  * `POST /api/auth/signup`: Register a new host.
  * `POST /api/auth/login`: Log in a host and receive a JWT.
  * `POST /api/quizzes`: Create a new quiz (requires auth).
  * `GET /api/quizzes`: Get all quizzes for the logged-in host (requires auth).
  * `POST /api/sessions/create`: Create a new live session from a quiz (requires auth).
  * `POST /api/sessions/join/:code`: Allows a player to join a session's database record.

\</details\>

\<details\>
\<summary\>\<strong\>WebSocket Events (`/live` namespace)\</strong\>\</summary\>

#### Emitted by Client:

  * `host:join`: Host authenticates and joins a lobby.
  * `player:join`: Player joins a lobby.
  * `host:start`: Host starts the quiz.
  * `host:next`: Host advances to the next question.
  * `player:answer`: Player submits an answer.

#### Emitted by Server:

  * `lobby:update`: Sent when the player list changes.
  * `question:show`: Sent to broadcast a new question to all clients.
  * `leaderboard:update`: Sent between questions with current scores.
  * `quiz:ended`: Sent when the quiz is over, with the final leaderboard.

\</details\>
