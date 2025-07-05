# Loyalty Mobile App

A modern Flutter mobile application for managing loyalty programs, punch cards, points, and rewards. This app integrates with the Loyalty Engine API to provide a comprehensive loyalty management experience.

## Features

### 🔐 Authentication
- User registration and login
- JWT token-based authentication
- Secure token storage
- Auto-logout on token expiration

### 📊 Dashboard
- Overview of user's loyalty status
- Quick stats (total points, active cards)
- Recent activity feed
- Quick navigation to main features

### 🎫 Punch Cards
- View all punch cards
- Earn punches on cards
- Redeem completed cards
- Progress tracking with visual indicators
- Detailed card information

### ⭐ Points System
- View point balance
- Transaction history
- Points earned vs redeemed tracking
- Real-time balance updates

### 🎁 Rewards
- Browse available rewards
- View reward details
- Filter by reward type
- Reward status tracking

### 🔔 Notifications
- Real-time notifications
- Mark notifications as read
- Notification history
- Different notification types (rewards, points, punch cards, system)

### 👤 User Profile
- User information display
- Account settings
- Logout functionality
- Role-based access control

## Architecture

The app follows a clean architecture pattern with the following structure:

```
lib/
├── core/
│   ├── models/           # Data models
│   ├── providers/        # State management (Provider pattern)
│   ├── services/         # API and storage services
│   ├── theme/           # App theming
│   └── routes/          # Navigation configuration
├── features/
│   ├── auth/            # Authentication feature
│   ├── dashboard/       # Dashboard feature
│   ├── punch_cards/     # Punch cards feature
│   ├── points/          # Points feature
│   ├── rewards/         # Rewards feature
│   ├── notifications/   # Notifications feature
│   └── profile/         # Profile feature
└── main.dart           # App entry point
```

## Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **UI Components**: Material Design 3
- **Theme**: Custom theme with light/dark mode support

## Platform Support

This app supports the following platforms:

- **Android** (mobile)
- **iOS** (mobile, requires Mac with Xcode)
- **Windows** (desktop)
- **Web** (Chrome, Edge, etc.)

You can build and run the app on any of these platforms. See below for platform-specific setup.

## Fonts & Assets

- Uses **Roboto Flex** as the primary font for a modern, readable UI.
- Ensure the `assets/fonts/` directory contains the Roboto Flex font files (see `pubspec.yaml` for details).
- Asset folders (e.g., `assets/images/`, `assets/icons/`) must exist, even if empty, to avoid build errors.

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK 2.19 or higher
- Android Studio / VS Code
- Android SDK (for Android)
- Xcode (for iOS, Mac only)
- Visual Studio with Desktop C++ workload (for Windows)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd loyalty-white-label-mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   # Windows (PowerShell)
   .\setup_env.ps1
   
   # Or manually copy the example file
   cp env.example .env
   ```
   
   Then edit `.env` file to configure:
   - `APP_NAME`: Your app name
   - `API_BASE_URL`: Your Loyalty Engine API server URL
   - `API_TIMEOUT`: API request timeout in milliseconds
   - Feature flags and other settings

4. **Enable desired platforms:**
   - **Android:**
     ```bash
     flutter create --platforms=android .
     ```
   - **iOS (on Mac):**
     ```bash
     flutter create --platforms=ios .
     ```
   - **Windows:**
     ```bash
     flutter create --platforms=windows .
     ```
   - **Web:**
     ```bash
     flutter create --platforms=web .
     ```

5. **Run the app:**
   - **Android:**
     ```bash
     flutter run -d android
     ```
   - **iOS:**
     ```bash
     flutter run -d ios
     ```
   - **Windows:**
     ```bash
     flutter run -d windows
     ```
   - **Web:**
     ```bash
     flutter run -d chrome
     ```
### Flutter Debug
Checks if the code is clean and follows best practices.
`flutter analyze --no-fatal-infos` 

Formats the code to follow the best practices.
`flutter format .`

Runs the tests.
`flutter test`

Runs the linter.
`flutter analyze --no-fatal-infos`

Builds the app for the selected platform.
`flutter build apk --release`

Runs the app on the selected platform.
`flutter run -d android`

Cleans the project.
`flutter clean`

Gets the dependencies.
`flutter pub get`

Checks the project for any issues.
`flutter doctor`

Upgrades the project to the latest version.
`flutter upgrade`

Downgrades the project to the latest version.
`flutter downgrade`

Runs the app on the selected platform.
`flutter run -d chrome --verbose`

Roboto Flex font files must be present in `assets/fonts/` and referenced in `pubspec.yaml`:

```yaml
fonts:
  - family: RobotoFlex
    fonts:
      - asset: assets/fonts/RobotoFlex-Regular.ttf
      - asset: assets/fonts/RobotoFlex-Bold.ttf
      - asset: assets/fonts/RobotoFlex-Italic.ttf
```

If you change fonts, update both the font files and the theme configuration in `lib/core/theme/app_theme.dart`.

### Asset Folders

Ensure these folders exist (even if empty):
- `assets/fonts/`
- `assets/images/`
- `assets/icons/`

### Environment Variables

The app uses environment variables for configuration. Create a `.env` file based on `env.example`:

```bash
# App Configuration
APP_NAME=Loyalty Mobile App
APP_VERSION=1.0.0

# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000

# Feature Flags
ENABLE_NOTIFICATIONS=true
ENABLE_QR_CODE=true

# Development
DEBUG_MODE=true
```

**Important:** The `.env` file is ignored by git for security. Each developer should create their own local copy.

## Troubleshooting

- **Missing platform error:** If you see errors like `This application is not configured to build on the web`, run the appropriate `flutter create --platforms=... .` command for your platform.
- **Missing font or asset errors:** Ensure all asset folders exist and the Roboto Flex font files are present as described above.
- **Android toolchain issues:** Run `flutter doctor` and follow the instructions to install missing SDK components or accept licenses.
- **iOS build issues:** Must be on a Mac with Xcode installed. Run `sudo xcode-select --switch /Applications/Xcode.app` if you have multiple Xcode versions.
- **Windows build issues:** Ensure Visual Studio with Desktop C++ workload is installed.

## API Integration

The app integrates with the following API endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /users/me` - Get current user

### Punch Cards
- `GET /punch-cards` - List all punch cards (admin)
- `GET /my-punch-cards` - List user's punch cards
- `POST /punch-cards` - Create punch card
- `GET /punch-cards/{id}` - Get punch card details
- `PUT /punch-cards/{id}` - Update punch card
- `DELETE /punch-cards/{id}` - Delete punch card
- `POST /punch-cards/{id}/earn` - Earn a punch
- `POST /punch-cards/{id}/redeem` - Redeem punch card

### Points
- `GET /point-transactions` - List all transactions (admin)
- `GET /my-point-transactions` - List user's transactions
- `POST /point-transactions` - Create transaction

### Rewards
- `GET /rewards` - List all rewards
- `POST /rewards` - Create reward

### Notifications
- `GET /notifications` - List all notifications (admin)
- `GET /my-notifications` - List user's notifications
- `PATCH /notifications/{id}/read` - Mark notification as read

## State Management

The app uses the Provider pattern for state management with the following providers:

- **AuthProvider**: Manages authentication state and user data
- **PunchCardProvider**: Manages punch card operations and state
- **PointTransactionProvider**: Manages point transactions and balance
- **RewardProvider**: Manages rewards data
- **NotificationProvider**: Manages notifications and read status

## Navigation

The app uses GoRouter for navigation with the following routes:

- `/login` - Login screen
- `/register` - Registration screen
- `/dashboard` - Main dashboard
- `/punch-cards` - Punch cards list
- `/punch-cards/:id` - Punch card details
- `/points` - Points and transactions
- `/rewards` - Available rewards
- `/notifications` - User notifications
- `/profile` - User profile

## Error Handling

The app includes comprehensive error handling:

- Network error handling with retry mechanisms
- Form validation with user-friendly error messages
- API error responses with proper user feedback
- Loading states for better UX
- Graceful degradation when services are unavailable

## Security Features

- JWT token authentication
- Secure token storage using SharedPreferences
- Automatic token refresh
- Role-based access control
- Input validation and sanitization

## Testing

To run tests:

```bash
flutter test
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

## Changelog

### Version 1.0.0
- Initial release
- Complete loyalty management functionality
- Modern UI with Material Design 3
- Full API integration
- Authentication and user management
- Punch cards, points, and rewards features
- Real-time notifications
- Profile management 