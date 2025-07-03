# 📦 AsyncStateView

A lightweight and reusable SwiftUI component that abstracts common patterns of handling asynchronous data states like **loading**, **success**, and **error**.

Designed to make your SwiftUI views cleaner and more maintainable by encapsulating loading logic in a simple, declarative API.

---
## Requirements
- iOS 17.0+
- Swift 6.0+
- SwiftUI

## Installation

### Swift Package Manager
Add `AsyncStateView` to your project via Swift Package Manager:

1. In Xcode, go to `File > Add Packages`.
2. Enter `https://github.com/zuhaibimtiaz/AsyncStateView.git`

Or add it directly to your `Package.swift`:

```swift
.package(url: "https://github.com/zuhaibimtiaz/AsyncStateView.git", from: "1.0.0")
```

---

## 🚀 Features

- 🌀 **Handle Async States Easily**: `.idle`, `.loading`, `.dataLoaded`, `.error`
- 🎨 **Customizable UI for Each State**
- 🔁 Built-in **Retry** and **Pull-to-Refresh** support
- 🧪 Built-in Preview for quick testing
- 🧼 Clean and Swifty API with default fallbacks

---

## 🧩 Components

### `AsyncLoadingState<Value>`

Enum to represent async data states:

```swift
enum AsyncLoadingState<Value> {
    case idle
    case loading
    case dataLoaded(Value)
    case error(Error)
}
```
### `Usage`
```swift

AsyncStateView(
    state: $state,
    loadingContent: { LoadingStateView() },
    dataContent: { data in Text(data) },
    errorContent: { error, retry in
        Text("Error: \(error.localizedDescription)")
    },
    fetchData: {
        try await Task.sleep(for: .seconds(2))
        return "Loaded Data"
    }
)
```
## `Example`

```swift
struct ExampleView: View {
    @State var state: AsyncLoadingState<String> = .idle
    @State var secondsDelay: Int = 3

    var body: some View {
        VStack {
            AsyncStateView(
                state: $state,
                loadingContent: { Text("Loading...") },
                dataContent: { Text($0).bold() },
                errorContent: { error, retry in
                    VStack {
                        Text("Error: \(error.localizedDescription)")
                        Button("Retry", action: retry)
                    }
                },
                fetchData: {
                    try await Task.sleep(for: .seconds(secondsDelay))
                    return "Hello, Async!"
                }
            )

            Button("Trigger Reload") {
                state = .idle
            }
        }
    }
}
```
