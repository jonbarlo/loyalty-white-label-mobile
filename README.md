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

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.19 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd loyalty-white-label-mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure the API endpoint:
   - Open `lib/core/services/api_service.dart`
   - Update the `baseUrl` constant to point to your Loyalty Engine API server

4. Run the app:
```bash
flutter run
```

### Configuration

#### API Configuration
The app is configured to connect to the Loyalty Engine API running on `http://localhost:3000`. To change this:

1. Open `lib/core/services/api_service.dart`
2. Update the `baseUrl` constant:
```dart
static const String baseUrl = 'https://your-api-server.com';
```

#### Theme Configuration
The app uses a custom theme defined in `lib/core/theme/app_theme.dart`. You can customize:

- Primary and secondary colors
- Text colors and typography
- Component styles (buttons, cards, etc.)
- Dark mode support

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