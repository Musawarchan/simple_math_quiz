# Math Drill MVP

A simple, child-friendly web application for practicing addition and multiplication drills with numbers 0-9.

## Features

### Phase 1 (Current MVP)
- **Addition Mode**: Practice adding numbers 0-9
- **Multiplication Mode**: Practice multiplying numbers 0-9
- **3-Second Timer**: Each question has a 3-second time limit
- **Scoring System**: Earn 1 point for each correct answer
- **Real-time Statistics**: Track score, total questions, and accuracy
- **Reset Functionality**: Start fresh sessions anytime
- **Child-Friendly UI**: Clean, pastel-colored interface with engaging visuals

## How to Play

1. Choose between Addition or Multiplication mode from the home screen
2. Answer each question within 3 seconds
3. Correct answers give you 1 point
4. Track your progress with real-time statistics
5. Use the reset button to start a new session

## Technical Details

- **Framework**: Flutter Web
- **Language**: Dart
- **Architecture**: Clean Architecture with Provider state management
- **State Management**: Provider pattern for reactive UI updates
- **Responsive Design**: Works on desktop and mobile browsers
- **Performance**: Lightweight and optimized for smooth gameplay

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration with Provider setup
├── core/                        # Core functionality
│   ├── theme/app_theme.dart     # App theming and colors
│   ├── constants/app_constants.dart # App constants and configuration
│   └── utils/math_utils.dart    # Utility functions
├── data/                        # Data layer
│   ├── models/math_models.dart  # Data models
│   ├── repositories/math_question_repository.dart # Data access
│   └── services/drill_session_service.dart # Business logic services
└── features/                    # Feature-based modules
    ├── home/
    │   └── view/home_view.dart
    ├── addition_drill/
    │   ├── view/addition_drill_view.dart
    │   └── viewmodel/addition_drill_viewmodel.dart
    ├── multiplication_drill/
    │   ├── view/multiplication_drill_view.dart
    │   └── viewmodel/multiplication_drill_viewmodel.dart
    └── shared/widgets/          # Shared UI components
        ├── timer_widget.dart
        └── answer_input_widget.dart
```

## Running the App

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run in web mode:
   ```bash
   flutter run -d web-server --web-port 8080
   ```

3. Open your browser and navigate to `http://localhost:8080`

## Future Features (Planned Phases)

- Progress tracking & performance statistics
- Customizable practice sessions
- Additional operations (subtraction, division, etc.)
- Gamification elements (levels, streaks, badges)
- Native mobile apps (iOS & Android)

## Browser Compatibility

- Chrome (recommended)
- Firefox
- Safari
- Edge

## License

This project is part of a custom development agreement.# simple_math_quiz
