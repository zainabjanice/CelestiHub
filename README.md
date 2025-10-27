# CelestiHub
*The Interactive Astronomy Database*

![Dart](https://img.shields.io/badge/Dart-2.13-blue)
![MySQL](https://img.shields.io/badge/MySQL-Database-orange)
![Web](https://img.shields.io/badge/Frontend-HTML%2FCSS-green)
![License](https://img.shields.io/badge/License-Apache2-yellow)

## Project Story 
For centuries, humanity has looked up at the night sky with curiosity,  mapping constellations, naming stars, and seeking meaning in the cosmos.
But in the digital age, exploring space shouldn’t be limited to telescopes and star charts; it should be interactive, collaborative, and intelligent.

**CelestiHub** was born from this idea, to create a modern astronomy web app that allows anyone, from students to researchers, to build their own universe.
Whether you’re cataloging exoplanets, tracking nebulae, or inventing a fictional galaxy, CelestiVault gives you the power to create, modify, and visualize celestial objects seamlessly through an elegant web interface.

## Problem Statement
Traditional astronomy databases are:

- Static and hard to customize
- Intimidating for non-experts
- Lacking visual interaction

This project aims to bridge the gap between astronomy and accessibility,  empowering users to manage astronomical data intuitively, without complex database queries.

## How the system works 
### 1. Frontend (Web Interface)
- Built with HTML, CSS, and Dart’s web framework.
- Users can add, edit, delete, and visualize celestial objects.
- Objects are dynamically displayed as part of an interactive celestial map.

### 2. Backend ( Dart Server)
- Handles all CRUD operations (Create, Read, Update, Delete).
- Built using Dart’s shelf and mysql_client libraries.
- Connects securely to a MySQL database.

### 3. DataBase (MySQL)
- Stores celestial objects with attributes such as name, type, distance, coordinates, and description.
- The backend automatically verifies tables and inserts sample data when launched.

### 4. Workflow

The project employs a straightforward yet efficient data flow pipeline that seamlessly connects the user interface, backend logic, and database storage.
- User interacts with the web UI
- Request is sent to the Dart backend
- Backend processes and updates the MySQL database
- Updated celestial data appears instantly on the interface

  
## Project Structure
```
astronomy_app/
├── backend/
│   ├── bin/server.dart        # Dart backend server
│   ├── pubspec.yaml           # Dependencies
│   └── pubspec.lock
└── frontend/
    └── index.html             # Web interface

```
## Features
- interactive celestial object management
- Real-time updates from the database
- Intuitive design for astronomy enthusiasts
- Scalable backend powered by Dart
- Open to community contributions

## Tech Stack
| Layer    | Technology                     |
| -------- | ------------------------------ |
| Frontend | HTML, CSS, Dart                |
| Backend  | Dart (`shelf`, `mysql_client`) |
| Database | MySQL                          |
| Tools    | VS Code, WebDev Server         |

## Future Enhancements
- Integrate 3D visualization using WebGL or Flutter Web
- Add user authentication for personalized universes
- Allow users to add an image for each celestial object
- Connect with real NASA/ESA APIs
- Implement AI-based celestial classification

## Getting Started
```
# Clone the repository
git clone https://github.com/<yourusername>/CelestiVault.git
cd astronomy_app/backend

# Install dependencies
dart pub get

# Run the backend server
dart run bin/server.dart

# Access the web interface
http://localhost:8081
```

## Contact

Zainab Jamil — AI Engineer in training💗👩‍💻

GitHub: github.com/zainabjanice — Email: jamilzainab91@gmail.com ✨😊



