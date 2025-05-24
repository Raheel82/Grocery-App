# 🛒 FireGraph Smart Grocery Recommender

## 📑 Table of Contents
- [Project Overview](#-project-overview)
- [Features](#-features)
- [Technology Stack](#-technology-stack)
- [System Architecture](#-system-architecture)
- [Installation](#-installation)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Graph Model](#-graph-model)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)
- [References](#-references)

---

## 📖 Project Overview

*FireGraph Smart Grocery Recommender* is a personalized grocery recommendation system that uses graph-based machine learning to analyze user interactions and provide intelligent suggestions.

It combines a cross-platform Flutter app with a Flask backend, Neo4j graph database, and Firebase authentication to deliver scalable and personalized grocery experiences.

---

## ✨ Features

- Personalized product recommendations based on user behavior
- Graph relationships like VIEWED, PURCHASED, SIMILAR_TO
- Recommender logic using collaborative filtering + category similarity
- Real-time suggestion performance via optimized Cypher queries
- Secure login, registration, and session management via Firebase
- Admin interface for managing product categories (optional)
- Easily extendable for promotions, preferences, etc.

---

## 🛠 Technology Stack

| Layer           | Technology         |
|-----------------|--------------------|
| Frontend        | Flutter            |
| Authentication  | Firebase           |
| Backend         | Flask REST API     |
| Database        | Neo4j              |
| Data Format     | Cypher             |
| Hosting         | Local / Cloud      |

---

##   System Architecture
+---------------------+
| Flutter App |
+---------------------+
|
v
+---------------------+
| Flask API |
+---------------------+
| |
v v
+--------+ +------------+
| Firebase| | Neo4j |
+--------+ +------------+


- *Frontend*: Built with Flutter for both Android and iOS
- *Backend*: Flask-based REST API communicates with Firebase and Neo4j
- *Database*: Neo4j stores user-product interactions and relationships
- *Authentication*: Firebase handles sign-in, sign-up, and session tokens

---

## 🚀 Installation

### ✅ Prerequisites

- Flutter SDK (>=3.0.0)
- Python (>=3.8)
- Node.js (>=16.0)
- Neo4j Desktop or Server (>=5.0)
- Firebase Project
- Git

### 🔧 Setup Instructions

#### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/firegraph-smart-grocery-recommender.git
cd firegraph-smart-grocery-recommender/backend
2. Set Up Backend
bash
# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Linux/MacOS
# venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export NEO4J_URI="bolt://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="your_password"
# For Windows: use 'set' instead of 'export'

# Run the application
python app.py
3. Set Up Frontend
bash
cd ../frontend
flutter pub get
flutter run
📲 Usage
Launch the Flutter app

Register or log in with Firebase

Browse grocery products

View tailored recommendations based on your behavior

Track your interaction history (viewed/purchased)

(Optional) Use admin panel for managing product categories

📂 Project Structure
firegraph-smart-grocery-recommender/
├── backend/
│   ├── app.py                # Flask application
│   ├── config.py             # Configuration settings
│   ├── requirements.txt      # Python dependencies
│   └── routes/               # API route definitions
├── frontend/
│   ├── lib/                  # Flutter application code
│   ├── pubspec.yaml          # Flutter dependencies
│   └── assets/               # Static assets
├── data/
│   ├── import.cypher         # Sample data import script
├── docs/
│   ├── Project_Report.pdf    # Project documentation
│   └── architecture_diagram.png
└── README.md
🌐 Graph Model
🧩 Nodes
User: {userID, name, email}

Product: {productID, name, price, category}

Category: {categoryID, name}

🔗 Relationships
(User)-[:VIEWED {timestamp}]->(Product)

(User)-[:PURCHASED {timestamp, quantity}]->(Product)

(Product)-[:BELONGS_TO]->(Category)

(Product)-[:SIMILAR_TO]->(Product)

🤝 Contributing
Fork the project

Create your feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request

📜 License
Distributed under the MIT License. See LICENSE for more information.

🙏 Acknowledgments
Team Members:

Muhammad Arslan Jameel (2022-CS-816)

Raheel Anjum (2022-CS-810)

Supervisor: Sir Talha

Institution: University of Engineering and Technology, Lahore (Faisalabad Campus)

Session: 2022–2026

📚 References
Neo4j Documentation

Flutter Documentation

Flask Documentation

Firebase Documentation

Gamma et al., Design Patterns

Ricci et al., Recommender Systems Handbook (Springer, 2011)

Cypher Query Language Reference


This README includes:
- Proper GitHub markdown formatting
- Consistent emoji usage
- Clear section organization
- Code blocks for commands
- ASCII architecture diagram
- Complete project structure
- Detailed installation instructions
- Graph model documentation
- All requested sections with proper links

The formatting matches GitHub's style and includes all the information from your original request while maintaining readability and professional presentation.
