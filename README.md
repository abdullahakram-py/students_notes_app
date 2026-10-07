# Students Notes App

A cross-platform note-taking application for students, built with Flutter. It lets students capture, organize, and share their study material with rich-text notes, attachments, and PDF export, with all data stored locally on the device.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/State-Riverpod-00B0FF)
![Hive](https://img.shields.io/badge/Storage-Hive-FFC107)

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Supported Platforms](#supported-platforms)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)

## Features

- **Rich-text editing** powered by Flutter Quill (formatting, lists, and more)
- **Attachments** for images and files, using the device gallery and file picker
- **PDF export and sharing** of notes through the system share sheet
- **Offline-first storage** with Hive, so notes stay available without a connection
- **Reactive state management** with Riverpod
- **Custom typography** using Google Fonts
- **Localization-ready** through Flutter's `intl` and localization support

## Screenshots

_Screenshots coming soon._

<!--
Add images to a docs/screenshots folder and reference them here:
<p align="center">
  <img src="docs/screenshots/home.png" width="250" />
  <img src="docs/screenshots/editor.png" width="250" />
</p>
-->

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.12.2`) |
| State management | [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) |
| Local storage | [`hive`](https://pub.dev/packages/hive), [`hive_flutter`](https://pub.dev/packages/hive_flutter), [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Rich-text editor | [`flutter_quill`](https://pub.dev/packages/flutter_quill) |
| Attachments | [`image_picker`](https://pub.dev/packages/image_picker), [`file_picker`](https://pub.dev/packages/file_picker) |
| PDF and sharing | [`pdf`](https://pub.dev/packages/pdf), [`printing`](https://pub.dev/packages/printing), [`share_plus`](https://pub.dev/packages/share_plus) |
| Device access | [`path_provider`](https://pub.dev/packages/path_provider), [`permission_handler`](https://pub.dev/packages/permission_handler) |
| UI and formatting | [`google_fonts`](https://pub.dev/packages/google_fonts), [`intl`](https://pub.dev/packages/intl) |
| Utilities | [`uuid`](https://pub.dev/packages/uuid), [`path`](https://pub.dev/packages/path) |

## Supported Platforms

The project includes platform folders for Android, iOS, Web, Windows, macOS, and Linux.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with a Dart SDK version compatible with `^3.12.2`
- An IDE such as Android Studio or VS Code with the Flutter plugin
- An emulator, simulator, or physical device (or a desktop/web target)

Verify your setup:

```bash
flutter doctor
```

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/abdullahakram-py/students_notes_app.git
   cd students_notes_app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

   To target a specific platform, use `flutter run -d <device>`, for example `-d windows` or `-d chrome`.

### Building a release

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (requires macOS)
flutter build web --release      # Web
flutter build windows --release  # Windows
```

## Project Structure

```text
students_notes_app/
├── android/          # Android platform code
├── ios/              # iOS platform code
├── linux/            # Linux platform code
├── macos/            # macOS platform code
├── web/              # Web platform code
├── windows/          # Windows platform code
├── lib/              # Application source code
├── test/             # Automated tests
├── pubspec.yaml      # Dependencies and project metadata
└── analysis_options.yaml  # Lint rules
```

## Testing

Run the test suite:

```bash
flutter test
```

Analyze the code against the project's lint rules (`flutter_lints`):

```bash
flutter analyze
```

## Roadmap

- [ ] Add screenshots and a short demo to this README
- [ ] Note search and organization (folders or tags)
- [ ] Cloud backup and sync
- [ ] Reminders for study tasks
- [ ] Expanded unit and widget test coverage

## Contributing

Contributions, issues, and feature requests are welcome.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to your branch: `git push origin feature/your-feature`
5. Open a pull request

## License

No license has been specified for this project yet. Add a `LICENSE` file (for example, MIT) to define how others may use the code.

## Author

**Abdullah Akram**

- GitHub: [@abdullahakram-py](https://github.com/abdullahakram-py)
- LinkedIn: [abdullah-akram07](https://www.linkedin.com/in/abdullah-akram07)
