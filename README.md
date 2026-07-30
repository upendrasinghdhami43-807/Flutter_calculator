# Flutter Advanced Mathematical Calculator 🧮

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/upendrasinghdhami43-807/Flutter_calculator/blob/main/LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)

A comprehensive, multi-platform, powerful calculator built with **Flutter**. This application ranges from simple daily arithmetic to complex scientific and advanced engineering mathematics, all processed locally without relying on external mathematical APIs.

## ✨ Features

### 🟢 Phase 1: Basic Calculator
- Standard arithmetic operations (+, -, *, /)
- Clean, intuitive, and responsive UI
- History ribbon

### 🔵 Phase 2: Scientific (Pro) Mode
- Advanced mathematical operations (trigonometry, logarithms, exponentials)
- Support for complex string parsing and evaluation (`ExpressionEvaluator`)
- Formatted expressions and intelligent cursor handling

### 🟣 Phase 3: Advanced Engineering Mathematics
- **Matrix Operations**: Determinant, Inverse, Eigenvalues/Eigenvectors, Adjoint. Supports fast-entry UI up to 4x4.
- **Equation Solver**: Solves linear systems of equations and polynomial root finding. 
- **Graphing Engine**: Beautiful, interactive function plotting (e.g., `sin(x)*e^x`). Supports pinch-to-zoom, panning, and coordinate inspections.
- **Conic Sections**: Dynamically inputs generic variables ($Ax^2 + Bxy + ...$) and renders geometric shapes classifying them in real time (Hyperbolas, Parabolas, Ellipses).
- **Calculus**: Symbolic differentiation, numeric integration (Simpson's Rule), and root bounding. *(UI currently in progress)*

## 🛠️ Architecture
- **Framework**: Flutter
- **State Management**: `flutter_riverpod` (using `NotifierProvider`)
- **Graphics**: `CustomPainter` & `InteractiveViewer` customized for mathematical coordinate spaces.
- **Algorithms**: Written strictly in Dart (Durand-Kerner, Gauss-Jordan, QR Algorithm, Numerical differentiation).

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK

### Installation
1. Clone the repository
```bash
git clone https://github.com/upendrasinghdhami43-807/Flutter_calculator.git
```
2. Navigate to the project directory
```bash
cd Flutter_calculator
```
3. Get Flutter packages
```bash
flutter pub get
```
4. Run the application
```bash
flutter run
```

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!
Feel free to check out the [issues page](https://github.com/upendrasinghdhami43-807/Flutter_calculator/issues).
If you'd like to contribute, please read our [CONTRIBUTING.md](CONTRIBUTING.md) guide.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Project Structure

```
.
├── analysis_options.yaml
├── android
│   ├── app
│   ├── build.gradle.kts
│   ├── flutter_calce_android.iml
│   ├── gradle
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── local.properties
│   └── settings.gradle.kts
├── flutter_calce.iml
├── ios
│   ├── Flutter
│   ├── Runner
│   ├── RunnerTests
│   ├── Runner.xcodeproj
│   └── Runner.xcworkspace
├── lib
│   └── main.dart
├── linux
│   ├── CMakeLists.txt
│   ├── flutter
│   └── runner
├── macos
│   ├── Flutter
│   ├── Runner
│   ├── RunnerTests
│   ├── Runner.xcodeproj
│   └── Runner.xcworkspace
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── test
│   └── widget_test.dart
├── web
│   ├── favicon.png
│   ├── icons
│   ├── index.html
│   └── manifest.json
└── windows
    ├── CMakeLists.txt
    ├── flutter
    └── runner

26 directories, 19 files
```

