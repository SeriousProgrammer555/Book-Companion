# Book Companion - Project Structure

## Core Features (Based on Requirements)

### 1. Book Management
- Add/Edit books
- Track reading progress
- Manage book status (Reading, Completed, On-Hold)
- View book details and statistics

### 2. Reading Experience
- Track characters
- Save quotes with page numbers
- Record lessons per chapter
- Track mood during reading sessions

### 3. Data Management
- Local storage (primary)
- Optional cloud sync
- Data export

## Folder Structure

```
lib/
├── core/                      # Core application setup
│   ├── app.dart              # Main app configuration
│   ├── routes.dart           # Route definitions
│   └── theme.dart            # App theme configuration
│
├── features/                  # Feature-based modules
│   ├── auth/                 # Authentication feature
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── books/                # Book management feature
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── reading/              # Reading experience feature
│   │   ├── characters/       # Character tracking
│   │   ├── quotes/          # Quote management
│   │   ├── lessons/         # Chapter lessons
│   │   └── mood/            # Reading mood tracking
│   │
│   └── profile/              # User profile feature
│       ├── screens/
│       ├── widgets/
│       └── services/
│
├── models/                    # Data models
│   ├── book.dart
│   ├── character.dart
│   ├── quote.dart
│   ├── lesson.dart
│   ├── mood_log.dart
│   └── user.dart
│
├── services/                  # Shared services
│   ├── storage/              # Local storage service
│   │   ├── hive_service.dart
│   │   └── local_storage.dart
│   │
│   ├── sync/                 # Cloud sync service
│   │   ├── firebase_service.dart
│   │   └── sync_manager.dart
│   │
│   └── export/               # Data export service
│       └── export_service.dart
│
└── utils/                     # Utility functions and constants
    ├── constants.dart
    ├── extensions.dart
    └── helpers.dart
```

## Key Components

### 1. Models
- `Book`: title, author, page count, progress, status
- `Character`: name, role, description, book reference
- `Quote`: text, page number, tags, book reference
- `Lesson`: content, chapter, book reference
- `MoodLog`: mood type, page number, date, book reference
- `User`: basic user information (optional)

### 2. Services
- Local Storage: Hive for offline-first functionality
- Cloud Sync: Firebase for optional data backup
- Export: PDF/CSV export functionality

### 3. Features
- Authentication (optional)
- Book Management
- Reading Experience
- Profile Management

### 4. UI Components
- Material Design 3
- Responsive layouts
- Dark/Light theme support
- Custom widgets for book tracking 