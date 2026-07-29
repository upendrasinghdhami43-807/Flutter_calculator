# SuperCalc Phase 2 and 3 Report

## Delivered

### Pro Mode

- Replaced the scientific-mode placeholder with a Riverpod-driven Pro calculator.
- Added fx-style keypad interactions with primary, SHIFT, and ALPHA labels; trigonometry, inverse trigonometry, logs, powers, factorial, roots, combinations, permutations, memory, Ans, angle units, variables, history, and an all-clear/delete workflow.
- Added a MODE sheet with COMP/CMPLX selection and direct, shared shortcuts to Matrix and Equation tools.
- Added a compact Tools sheet for GCD, LCM, floor, ceiling, combinatorics, and variable store/recall.
- Added `floor`, `ceil`, `gcd`, and `lcm` to the shared expression evaluator.

### Advanced Mode

- Replaced the placeholder with a seven-tool scrollable engineering workbench.
- Added Matrix tool with 2x2 through 4x4 editable grids and determinant, inverse, transpose, rank, real eigenvalues, addition, subtraction, and multiplication.
- Added Equation tool with quadratic/cubic/quartic polynomial templates and 2x2 through 4x4 linear-system templates.
- Added Graph Finder and Conic Value Finder over one shared workspace, solver, and painter. It supports shape templates, manual parameters, free-form canonical equations, graph pan/zoom, and values including vertices, foci, axes, eccentricity, directrices, asymptotes, and latus rectum.
- Added Calculus, LPP, and Graph 3D placeholder routes with standard app-bar back navigation.
- Converted Home navigation to `context.push(...)`; all mode and Advanced routes now maintain a real back stack.

## Files Added or Updated

- `lib/features/scientific/`: Pro controller, display/top bar, mode/tools sheets, keypad, and screen.
- `lib/features/advanced/matrix/`: matrix controller and screen.
- `lib/features/advanced/equation/`: polynomial wrapper, system wrapper, controller, and screen.
- `lib/features/advanced/conic/`: canonical equation parser, shared workspace, and value-finder screen.
- `lib/features/advanced/graph_finder/`: graph-finder route screen.
- `lib/features/advanced/placeholders/`: reusable deferred-feature screen.
- `lib/core/conics/`: classifier, complete solver/geometry pipeline, and painter.
- `lib/core/router/app_router.dart`, `lib/features/home/home_screen.dart`: Advanced routes and push-based navigation.
- `test/`: controller, parser, history, navigation, conic, and core-engine coverage.

## Verification Performed

- `flutter analyze`: **No issues found**.
- `flutter test`: **50 tests passed**.
- Navigation smoke test: Home -> Advanced -> Matrix -> back returns to the Advanced workbench.
- Conic known-answer checks passed:
  - `x^2 + y^2 - 4 = 0` -> circle, radius 2, center (0, 0).
  - `x^2 - 4y = 0` -> upward parabola, vertex (0, 0), focus (0, 1).
  - `9x^2 + 4y^2 - 36 = 0` -> ellipse, semi-major axis 3, semi-minor axis 2, eccentricity sqrt(5)/3.
  - `x^2 - y^2 - 1 = 0` -> rectangular hyperbola, a = b = 1, vertices (+/-1, 0).
- Matrix controller checks passed for determinant, inverse formatting, and invalid input.
- Equation controller checks passed for quadratic roots, unique linear systems, and invalid input.
- History checks passed for add, pin, and clearing only unpinned records.

## Intentional Consolidations and Deferrals

- History uses `shared_preferences` with JSON rather than the originally specified Drift/SQLite. It preserves local, restart-safe history without adding a code-generation pipeline for a small flat record list.
- The calculator uses a phone-friendly 7x5 keypad plus a Tools sheet rather than a literal hardware 8x6 fx-991EX grid. SHIFT and ALPHA labels remain visible on relevant keys.
- The symbolic differentiator was implemented early to support later Calculus work.
- Calculus, LPP, and Graph 3D are visible, navigable placeholders for future phases.
- Graph Finder and Conic Value Finder share one conic workspace. This deliberately merges the overlapping graph/value workflows while retaining both routes and both entry tabs.
