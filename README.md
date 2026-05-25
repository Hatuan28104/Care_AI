# Care AI - AI Health Tracking System

Care AI is a multi-component health tracking system that helps users manage personal health data, receive health alerts, connect with family members, and interact with AI-powered features for self-assessment and stress prediction.

The system includes a Flutter mobile application, a Node.js/Express backend API, a Python FastAPI AI service, a web admin portal, and native Android support for Health Connect integration.

## My Role

I worked as the main developer of this project, responsible for developing and integrating most parts of the system, including:

- Designing and developing the Flutter mobile application
- Building the Node.js/Express backend API
- Developing the FastAPI AI service
- Integrating Supabase database and Firebase Cloud Messaging
- Implementing authentication, profile, notification, chat, digital human, and health-related features
- Connecting the mobile app with backend APIs and AI services
- Managing source code, commits, debugging, and deployment preparation

## Tech Stack

### Mobile App
- Flutter
- Dart
- Firebase Messaging
- Flutter Local Notifications
- Shared Preferences
- Bluetooth integration
- Health metrics integration
- Camera and permission handling

### Backend
- Node.js
- Express.js
- Supabase
- Firebase Admin
- JWT Authentication
- REST API
- Multer
- OpenAI API

### AI Service
- Python
- FastAPI
- Machine Learning models
- Joblib
- Stress prediction model
- Self-evolution/self-assessment model

### Web Admin
- HTML
- CSS
- JavaScript
- Static web portal

### Tools
- Git / GitHub
- VS Code
- Postman
- Figma
- Draw.io

## Main Features

### User & Authentication
- User authentication
- JWT-based authorization
- User profile management
- Save and manage FCM token for push notifications

### Health Tracking
- Personal health profile management
- Health metrics tracking
- Health data processing
- Health Connect / Android native support

### Notification System
- Firebase Cloud Messaging integration
- Foreground and background push notifications
- Local notification handling

### Family Center
- Family-related APIs
- User connection and family health support features

### AI Features
- AI-powered self-assessment
- Stress prediction using machine learning model
- AI service separated from the main backend
- FastAPI endpoints for AI modules

### Chat & Digital Human
- Chat API
- Digital human API
- OpenAI API integration for intelligent interaction

### Admin Portal
- Web admin entry page
- Authentication pages
- Dashboard pages
- User, setting, and digital feature pages

## System Architecture

```text
Care_AI/
├── mobile_app/          # Flutter mobile application
├── backend/             # Node.js / Express backend API
├── ai_service/          # Python FastAPI AI service
├── web_admin/           # Static web admin portal
├── tmp_healthconnect/   # Android native / Health Connect support files
└── README.md
