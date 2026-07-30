# Contributing to Flutter Calculator

First off, thank you for considering contributing to this open-source project! It's people like you that make the open-source community such a fantastic place to learn, inspire, and create.

## 1. Where do I go from here?

If you've noticed a bug or have a question, [search the issues](https://github.com/upendrasinghdhami43-807/Flutter_calculator/issues) first to see if someone else has already opened one. If not, feel free to open a new issue.

## 2. Setting up your environment

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/upendrasinghdhami43-807/Flutter_calculator.git
   ```
3. **Add upstream**:
   ```bash
   git remote add upstream https://github.com/upendrasinghdhami43-807/Flutter_calculator.git
   ```

## 3. Workflow for making changes

1. **Branch**: Create a new branch for your feature or bugfix.
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Develop**: Make your changes locally.
3. **Test**: Run `flutter test` to ensure that all core logic continues to pass. Remember to write new tests if you introduce a core mathematical engine feature.
4. **Commit**: Keep your commit messages clean and descriptive.
5. **Push**: Push your branch to GitHub.
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Pull Request**: Go to the original repository and open a Pull Request (PR) describing the changes you made.

## 4. Coding Standards

- **State Management**: We use `flutter_riverpod`. Keep business logic outside of Widgets unless it's purely UI manipulation.
- **Formatting**: Run `dart format .` before committing.
- **Analysis**: Ensure `flutter analyze` runs without errors or warnings.
- **Math Accuracy**: Any changes to `core/` math engines *must* have accompanying unit tests.

Thank you again for contributing!