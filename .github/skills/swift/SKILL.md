---
name: swift
description: 'iOS Swift coding conventions for this project. ALWAYS load when writing, reviewing, refactoring, or editing any Swift (.swift) file. Covers naming conventions (Updater/Model suffix, folder prefix), @Observable state management, Swift concurrency (actors, async/await), SwiftUI modern API, UIKit builder pattern, view structure, accessibility, animation, colors, typography, and error handling. BLOCKING REQUIREMENT: must be loaded before any Swift code is generated or modified.'
---

# Swift Rules

## Context7 — Library & API Documentation

> **BLOCKING RULE — ZERO EXCEPTIONS:** Before writing or modifying any code that uses a third-party library, Apple framework, SDK, or external API, the agent MUST fetch current documentation via Context7. Relying on training-data knowledge alone is **always wrong** — APIs change across versions and outdated code is a critical error.

- MUST call `mcp_context7_resolve-library-id` first to locate the correct library ID
- MUST call `mcp_context7_query-docs` with a focused topic query before generating any usage of that library
- MUST apply this rule even for well-known frameworks: SwiftUI, UIKit, AVFoundation, CoreML, Vision, Combine, StoreKit, PhotosUI, etc.
- MUST NOT skip Context7 lookups on the assumption that the API is "stable" or "well-known"
- MUST re-query Context7 if a compile error or deprecation warning suggests the API has changed

```
// Correct workflow before using any framework or library
1. mcp_context7_resolve-library-id  →  find library ID
2. mcp_context7_query-docs          →  fetch relevant API docs
3. Write / modify code based on the fetched docs
```

## Naming & Coding Conventions

### Class / Struct / Enum Naming

Use this table to determine prefix and suffix:

| Location | Owned By | Suffix | Prefix? | Example |
|---|---|---|---|---|
| View/UIView folder | `struct` View directly | `Updater` | Yes | `HomeUpdater` |
| View/UIView folder | An `*Updater` | `Model` | Yes | `HomeContentModel` |
| Utility folder (`Package/`, `Module/`, `Config/`, `Helpers/`, etc.) | Any | descriptive | No | `ImageProcessor` |

- MUST prefix types in a view folder with the folder name: e.g. types in `Edit/` start with `Edit` (`EditUpdater`, `EditToolModel`), types in `Home/` start with `Home` (`HomeView`, `HomeUpdater`).
- MUST NOT apply the prefix rule to shared/utility folders — use clear descriptive names there.

**`@Observable` naming rule:**
- MUST end class name with `*Updater` when it is owned directly by a `struct` View (e.g. `@State var homeUpdater = HomeUpdater()`)
- MUST end class name with `*Model` when it is owned by an `*Updater` (e.g. `EditUpdater` owns `EditContentModel` and `EditToolModel`)

### Function Signatures

> **BLOCKING RULE — ZERO EXCEPTIONS:** Every function signature MUST be written on a single line. Splitting a signature across multiple lines is **always wrong**, regardless of length, number of parameters, or line width. There is no scenario where wrapping a signature is acceptable. Violating this rule is a critical error.

- MUST keep the entire signature — name, all parameters, and return type — on **one line**
- MUST NOT wrap parameters to the next line under any circumstances
- MUST NOT place each parameter on its own line even if there are 5, 6, or more parameters
- MUST NOT add trailing commas or line breaks between parameters
- Long signatures are fine on one line — **length is never a reason to wrap**

```swift
// ✅ CORRECT — always one line, no matter how many parameters
func process(image: UIImage, mask: UIImage, expand: CGFloat) -> UIImage
func process(image: UIImage, mask: UIImage, expand: CGFloat, blendMode: CGBlendMode, outputScale: CGFloat) -> UIImage
func applyEdit(image: UIImage, mask: UIImage, brushSize: CGFloat, opacity: Float, blendMode: CGBlendMode) -> UIImage

// ❌ WRONG — NEVER do this, not even for 2 parameters
func process(
    image: UIImage,
    mask: UIImage
) -> UIImage

// ❌ WRONG — NEVER do this, not even for 5+ parameters
func applyEdit(
    image: UIImage,
    mask: UIImage,
    brushSize: CGFloat,
    opacity: Float,
    blendMode: CGBlendMode
) -> UIImage
```

### Function Calls

> **BLOCKING RULE — ZERO EXCEPTIONS:** Every function call MUST be written on a single line. Splitting arguments across multiple lines is **always wrong**, regardless of argument count or length. There is no scenario where wrapping a call site is acceptable. Violating this rule is a critical error.

- MUST keep all arguments on **one line** — from `(` to `)`
- MUST NOT place each argument on its own line under any circumstances
- MUST NOT add trailing closures on a new indented line when the call can stay on one line
- Long call sites are fine on one line — **length is never a reason to wrap**

```swift
// ✅ CORRECT — always one line
let result = process(image: img, mask: mask, expand: 1.5)
let result = process(image: img, mask: mask, expand: 1.5, blendMode: .normal, outputScale: 2.0)
let result = applyEdit(image: originalImage, mask: maskImage, brushSize: 20.0, opacity: 0.8, blendMode: .normal)

// ❌ WRONG — NEVER do this, not even for 2 arguments
let result = process(
    image: img,
    mask: mask
)

// ❌ WRONG — NEVER do this, not even for 5+ arguments
let result = applyEdit(
    image: originalImage,
    mask: maskImage,
    brushSize: 20.0,
    opacity: 0.8,
    blendMode: .normal
)
```

### General Rules

- MUST use `fileprivate` over `private` when multiple types in the same file need access
- MUST place file-scoped constants that are not exposed at the top of the file as `fileprivate let`
- MUST use `guard` for early exits rather than nested `if`
- MUST avoid `@discardableResult` unless the return value is genuinely optional to the caller

### `guard` Formatting

Two rules depending on the number of conditions:

**Single condition `guard` and `else { <exit> }` on the same line**, <exit> MUST wrap if more than 1 statement include return, break, continue, throw, etc.

> **BLOCKING RULE — ZERO EXCEPTIONS:** A `guard` with exactly one condition MUST be written entirely on a single line — keyword, condition, `else`. There is no scenario where a single-condition `guard` may be split. Violating this rule is a critical error.

- MUST keep `guard <condition> else { <exit> }` on **one line**, <exit> MUST wrap if more than 1 statement include return, break, continue, throw, etc.
- MUST NOT split a single-condition guard onto multiple lines for any reason

```swift
// ✅ CORRECT — single condition, all on one line
guard let image = source else { return }
guard !items.isEmpty else { return }
guard let track = asset.tracks(withMediaType: .video).first else { 
    completion(.failure(err))
    return 
}

// ❌ WRONG — single condition split across lines
guard let image = source
else { return }

guard
    let image = source
else { return }
```

**Multiple conditions → each condition on its own line, first condition has the `guard` keyword in same line, `else { <exit> }` on the closing line**, <exit> MUST wrap if more than 1 statement include return, break, continue, throw, etc.

- MUST place each condition on its own indented line, first condition has the `guard` keyword in same line
- MUST place `else { <exit> }` on the final line after the last condition, <exit> MUST wrap if more than 1 statement include return, break, continue, throw, etc.
- MUST NOT write all conditions on one line when there are two or more

```swift
// ✅ CORRECT — multiple conditions, each on its own line, else { } closes
guard let image = source,
      let mask = maskSource,
      !image.size.equalTo(.zero)
else { return }

guard let url = URL(string: raw),
      let data = cache[url],
      !data.isEmpty
else { 
    completion(.failure(err))
    return 
}

// ❌ WRONG — all conditions jammed onto one line
guard let a = foo, let b = bar, let c = baz else { return }

// ❌ WRONG — else { } on a line of its own (not the closing line of the conditions)
guard
    let a = foo,
    let b = bar
else {
    return
}
```

## Patterns & Conventions

### State Management

- MUST use `@Observable` class (iOS 17 Observation framework) for all view models — **not** `ObservableObject`
- MUST mark `@Observable` classes with `@MainActor` unless the project has Main Actor default actor isolation enabled
- MUST inject via `.environment(updater)` at view root; access with `@Environment(Type.self)`
- MUST use `@Bindable var model = ...` inside `body` to get bindings from `@Observable` objects
- MUST use `@ObservationIgnored` on weak references and callbacks inside `@Observable`
- MUST NOT use `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`
- MUST mark `@State` properties as `private` — they are owned only by the view that created them
- MUST avoid `Binding(get:set:)` in view body; use `@State` with `onChange()` to trigger side effects instead
- MUST prefer making structs conform to `Identifiable` over `id: \.someProperty` in SwiftUI code

#### UIKit Builder Pattern

UIView setup uses chained `.e`-prefixed methods (`.eaddSubview()`, `.edelegate()`, `.emaximumZoomScale()`, etc.) from `UIViewHelpers`. MUST use this established pattern for all UIKit view setup. See `references/uikit-helpers.md` for the full list of available `.e`-prefixed methods. For any UIKit method not listed there, MUST apply the same pattern: prepend `e` to the method name and call it as a chainable method returning `Self`.

### Animation

- MUST use `.smooth(duration: ANIM_DURATION)` for all animations
- MUST always specify `value:` parameter to drive the animation
- MUST NOT use `animation(_ animation:)` without a `value:` parameter
- MUST chain animations using a `completion:` closure passed to `withAnimation()`, not multiple `withAnimation()` calls with delays

### Colors

- MUST NOT use raw `Color(red:green:blue:)` or `UIColor(red:green:blue:)` literals
- MUST use named color asset extensions, e.g. `Color.primary` resolves to the `Primary` color set in `Colors.xcassets`. Access them via the generated `Color` extensions (e.g. `Color.background`, `Color.gray30`). MUST NOT construct colors inline with component values.
- MUST use system `Color` values (`Color.green`, `Color.red`, `Color.blue`, `Color.white`, etc.) when they fit the UI context

### Typography

- MUST use `.font(.system(size: N, weight: .semibold, design: .rounded))` for UI chrome
- MUST prefer Dynamic Type (`.font(.body)`, `.font(.headline)`, etc.) for user-facing content text — MUST NOT force fixed sizes for readable content

### Error Handling

- MUST catch errors at the `*Updater` boundary; MUST NOT propagate `throws` into a SwiftUI view `body`.
- MUST store errors as `var error: Error?` on the Updater and surface them via `.alert(item:)` in the View.
- MUST prefer typed errors (`enum MyError: Error`) over bare `Error` where the caller can meaningfully recover.

## State Management (`@Observable`)

- MUST use `@Observable` + `@MainActor` for model classes (iOS 17+); MUST NOT use `ObservableObject`/`@Published`
- MUST store `@Observable` instances with `@State`, not `@StateObject`
- MUST read `@Observable` from the environment with `@Environment(Type.self)`, not `@EnvironmentObject`
- MUST inject into the environment with `.environment(myInstance)` (no key path)

```swift
@Observable
@MainActor
final class AppState {
    var isLoggedIn = false
}

// Inject
ContentView().environment(AppState())

// Read in child view
struct ChildView: View {
    @Environment(AppState.self) private var appState
}
```

## iOS 26 — Liquid Glass

- MUST use `glassEffect(_:in:)` to apply Liquid Glass to a view shape
- MUST group multiple glass elements in `GlassEffectContainer` so they sample a shared region
- MUST use `glassEffectID(_:in:)` inside a `GlassEffectContainer` for morphing animations
- MUST always guard with `if #available(iOS 26, *)` and provide a `.ultraThinMaterial` fallback
- MUST only adopt Liquid Glass when explicitly required — MUST NOT proactively convert existing UI

```swift
// Basic glass card
if #available(iOS 26, *) {
    content.glassEffect(.regular, in: .rect(cornerRadius: 20))
} else {
    content.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
}

// Grouped glass buttons with morphing
if #available(iOS 26, *) {
    GlassEffectContainer(spacing: 8) {
        HStack(spacing: 8) {
            Button("A") { }.glassEffect(.regular.interactive(), in: .capsule)
                .glassEffectID("a", in: animation)
            Button("B") { }.glassEffect(.regular.interactive(), in: .capsule)
                .glassEffectID("b", in: animation)
        }
    }
}
```

## Modern API

- MUST use `foregroundStyle()` instead of `foregroundColor()`
- MUST use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`
- MUST use the `Tab` API instead of `tabItem()`
- MUST NOT use `onChange()` in its 1-parameter variant; MUST use the 2-parameter or 0-parameter variant
- MUST NOT use `onTapGesture()` unless you specifically need tap location or tap count — MUST use `Button` for everything else
- MUST avoid `GeometryReader` if a newer alternative works (`containerRelativeFrame()`, `visualEffect()`, `Layout` protocol)
- MUST prefer `overlay(alignment:content:)` over the deprecated `overlay(_:alignment:)`
- MUST NOT use system toolbar APIs (`.toolbar {}`, `ToolbarItem`, `ToolbarItemGroup`, `ToolbarItemPlacement`, etc.) — MUST use `safeAreaInset(edge:)` or manually positioned views instead
- MUST NOT use `.navigationBarLeading` / `.navigationBarTrailing`; MUST use `.topBarLeading` / `.topBarTrailing`
- MUST NOT concatenate `Text` with `+`; MUST use text interpolation (`Text("\(red)\(blue)")`) instead
- MUST use `.scrollIndicators(.hidden)` not `showsIndicators: false` in scroll view initializers
- MUST NOT convert to array first for `ForEach` over `enumerated()` — MUST use `ForEach(items.enumerated(), id: \.element.id)` directly
- MUST prefer `sensoryFeedback()` over UIKit feedback generators (`UIImpactFeedbackGenerator`, etc.)
- MUST use `@Entry` macro for custom `EnvironmentValues`, `FocusValues`, `Transaction`, and `ContainerValues` keys
- MUST use `#Preview` macro for previews, not the legacy `PreviewProvider` protocol
- MUST apply `bold()` to make text bold — MUST NOT use `fontWeight(.bold)` or `fontWeight()` without a specific reason
- MUST always use `NavigationStack`; MUST NOT use the deprecated `NavigationView`
- MUST use `navigationDestination(for:)` for navigation destinations; MUST avoid the old `NavigationLink(destination:)` pattern
- MUST prefer `sheet(item:)` over `sheet(isPresented:)` when presenting optional data
- MUST use `ImageRenderer` to render SwiftUI views to images — MUST NOT use `UIGraphicsImageRenderer`

## View Structure

- MUST NOT break up `body` using computed properties or methods returning `some View` — MUST extract to separate `View` structs in their own files instead
- MUST place each type (struct, class, enum) in its own Swift file
- MUST extract button actions from `body` into separate methods
- MUST NOT place business logic inline in `task()`, `onAppear()`, or elsewhere in `body`
- MUST use `task()` over `onAppear()` for async work — it cancels automatically when the view disappears
- MUST avoid `AnyView` unless absolutely required; MUST use `@ViewBuilder`, `Group`, or generics instead
- MUST prefer `TextField` with `axis: .vertical` over `TextEditor` unless a full-screen editing experience is needed

## Accessibility

- MUST use `Image(decorative:)` or `.accessibilityHidden(true)` for decorative images; MUST add `.accessibilityLabel()` to all other images
- MUST always include text for buttons with image-only labels: `Button("Label", systemImage: "plus", action: myAction)` — MUST NOT use icon-only without a label
- MUST add `.accessibilityAddTraits(.isButton)` if `onTapGesture()` is used for a tappable element
- MUST respect `.accessibilityDifferentiateWithoutColor` with icons, patterns, or strokes if color is a key differentiator

## Deployment Target

This project targets **iOS 17+**. All iOS 17 APIs (`@Observable`, `withAnimation` completion closure, etc.) are available. MUST NOT add `#available` guards for iOS 17 features unless explicitly noted.

## Async / Concurrency

- MUST mark all ML inference and network calls as `async throws`
- MUST store long-running tasks as `Task` on the model so they can be cancelled
- MUST use `actor` for any heavy or CPU/IO-bound work (ML inference, image processing, network requests, file I/O)
- MUST always call `try Task.checkCancellation()` inside pipeline loops
- MUST prefer structured concurrency (`withTaskGroup`, `withThrowingTaskGroup`) over unstructured `Task {}`
- MUST NOT use Grand Central Dispatch (`DispatchQueue.main.async()` etc.) — MUST always use modern Swift concurrency
- MUST NOT use `Task.sleep(nanoseconds:)`; MUST use `Task.sleep(for:)` instead
- MUST avoid `Task.detached()` — check any usage carefully; it breaks structured cancellation
- MUST NOT use `@unchecked Sendable` to silence concurrency errors; MUST prefer actors, value types, or `sending` parameters

### Actor Reentrancy

After every `await` inside an actor, all assumptions about the actor's state are invalidated — other callers may have run in the meantime. MUST always capture results in locals before and after suspension points, and MUST NOT assume state is unchanged across an `await`.

```swift
// ❌ wrong — items[key] may have changed after the await
func fetch(_ key: String) async throws -> Data {
    if items[key] == nil {
        items[key] = try await download(key)
    }
    return items[key]!
}

// ✅ correct — capture result locally, then assign
func fetch(_ key: String) async throws -> Data {
    if let cached = items[key] { return cached }
    let data = try await download(key)
    items[key] = data
    return data
}
```