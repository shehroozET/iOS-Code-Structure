# 📱 Sample iOS Project — Albums & Media Sharing App

## Overview

This project is a **Sample iOS Application** demonstrating a clean architecture, scalable structure, and best practices for building a **Media Albums & Sharing Platform**.

The app allows users to:

* Register & Login securely
* Reset password
* Use Passcode authentication
* Create albums
* Upload photos & videos
* Share albums with other users
* Manage shared folders
* Browse dashboard with albums and shared content

This repository is **intended only as a sample codebase** to demonstrate **coding standards, architecture, and development practices**.

---

# ✨ Features

## 🔐 Authentication

### Login

* Secure user login
* Input validation
* Error handling
* Loading states

### Register

* User registration
* Email validation
* Password validation
* API integration ready

### Forgot Password

* Email-based password reset
* Validation handling
* API integration ready

### Passcode Functionality

* 4/6 digit passcode
* Passcode confirmation
* Passcode verification
* Secure access after login

---

# 🏠 Dashboard

The dashboard serves as the **main landing screen** after login.

### Dashboard Features

* View User Albums
* View Shared Albums
* Create New Album
* Search Users
* Quick Navigation
* Pull to refresh support

---

# 📁 Albums Management

Users can create and manage albums.

### Album Features

* Create New Album
* Edit Album Name
* Delete Album
* View Album Details
* Upload Media

---

# 📸 Media Upload

Users can upload media to albums.

### Upload Features

* Upload Images
* Upload Videos
* Multiple Selection Support
* Progress Indicator
* Error Handling

Supported Media Types:

* Images (JPG, PNG, HEIC)
* Videos (MP4, MOV)

---

# 👥 Share Albums

Albums can be shared with other users.

### Sharing Features

* User Search
* Select Multiple Users
* Share Album
* Shared Folder Access
* Permission Handling (View Only)

---

# 🔎 User Search

Search users to share albums.

### Search Features

* Search by Name
* Search by Email
* Debounced Search
* Empty State Handling

---

# 📂 Shared Folders

Users can access albums shared with them.

### Shared Folder Features

* View Shared Albums
* View Shared Media
* Read-only access
* Owner information display

---

# 👤 Profile & Settings

Users can manage their profile and application preferences.

### Profile Features

* Change Password
* Update Profile Information
* Notification Settings
* Enable / Disable Notifications
* Logout

### Notification Features

* Push Notifications (Ready for integration)
* In-App Notifications
* Notification Preferences
* Toggle Notification Settings

---

# 🏗 Architecture

This project follows a **modular and scalable folder structure** designed for maintainability and clean code practices.

## Project Structure

```
Project
│
├── API Manager
│   └── Models
│
├── Controllers
│   ├── Cells
│   ├── Custom Classes
│   ├── Main Controllers
│   └── Settings
│
├── Delegates
├── Fonts
├── Helper
├── Storyboards
```

---

## Folder Explanation

### API Manager

Handles all networking and API-related functionality.

Includes:

* API Calls
* Request Handling
* Response Parsing
* Error Handling

#### Models

* API Response Models
* Request Models
* Data Mapping

---

### Controllers

Contains all view controllers used in the application.

#### Cells

* TableView Cells
* CollectionView Cells
* Reusable UI Components

#### Custom Classes

* Custom UI Views
* Reusable Components
* Base Classes

#### Main Controllers

* Login
* Register
* Dashboard
* Albums
* Upload
* Sharing
* Profile

#### Settings

* Profile Settings
* Change Password
* Notification Settings

---

### Delegates

Contains:

* Protocol Definitions
* Delegate Handlers
* Communication Between Controllers

---

### Fonts

Contains:

* Custom Fonts
* Font Extensions
* Font Management

---

### Helper

Contains:

* Utility Classes
* Extensions
* Constants
* Common Functions

---

### Storyboards

Contains:

* Main Storyboard
* Authentication Storyboards
* Dashboard Storyboards
* Settings Storyboards

---

# 🧠 Architecture Principles

* MVVM Architecture
* Modular Structure
* Reusable Components
* Protocol-Oriented Programming
* Dependency Injection Ready
* Scalable Design

---

# 🛠 Technologies Used

* Swift
* UIKit
* MVVM Architecture
* URLSession / Networking Layer
* Auto Layout
* Storyboards / Programmatic UI (Depending on Implementation)

---

# 🔒 Security Considerations

* Secure passcode handling
* Secure API architecture
* Input validation
* Error handling

---

# 📦 Installation

### Requirements

* Xcode 15+
* iOS 15+
* Swift 5+

### Steps

1. Clone repository

```
git clone <repository-url>
```

2. Open project

```
Open .xcodeproj or .xcworkspace
```

3. Run Project

* Select device/simulator
* Press Run

---

# 📱 Screens Included

* Login Screen
* Register Screen
* Forgot Password Screen
* Passcode Screen
* Dashboard Screen
* Albums List Screen
* Album Detail Screen
* Upload Media Screen
* User Search Screen
* Shared Albums Screen

---

# 🧩 Code Highlights

This project demonstrates:

* Clean code practices
* Scalable folder structure
* Reusable UI components
* Networking abstraction
* Error handling
* Separation of concerns

---

# 🚀 Future Improvements (Optional)

* Real backend integration
* Push notifications
* Album permissions (Edit/View)
* Offline support
* Pagination
* Media compression

---

# ⚠️ Important Note

This repository is **NOT a production-ready application**.

This project is created **only as a sample codebase** to:

* Demonstrate coding style
* Show project structure
* Explain architecture decisions
* Provide development reference

The functionality may be **partially mocked**, **simplified**, or **not connected to a real backend**.

This repository is intended **only to give an idea of how we write code, structure projects, and implement features**.

---

# 👨‍💻 Author

Sample Project for Code Review / Architecture Demonstration

---

# 📄 License

This project is provided for **demonstration purposes only**.

---

# ⭐ Thank You

If you find this helpful, feel free to use it as a reference for project architecture and coding practices.

---

**This repository is strictly provided as a sample codebase to understand development approach and structure.**
