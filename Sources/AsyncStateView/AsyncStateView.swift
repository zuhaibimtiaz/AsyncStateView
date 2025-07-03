
// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
// A generic SwiftUI view for handling asynchronous data loading states.
public struct AsyncStateView<
    ViewData: Equatable & Sendable, // Data type must be equatable and safe for concurrency.
    LoadingContent: View,           // Custom view for loading state.
    DataContent: View,             // Custom view for displaying loaded data.
    ErrorContent: View             // Custom view for error state.
>: View {
    // Binding to the current loading state, allowing external updates.
    @Binding var state: AsyncLoadingState<ViewData>
    // Closure to provide the loading view content.
    @ViewBuilder var loadingContent: () -> LoadingContent
    // Closure to provide the view content when data is loaded.
    @ViewBuilder var dataContent: (ViewData) -> DataContent
    // Closure to provide the error view content when an error occurs, now accepting a retry action.
    @ViewBuilder var errorContent: (Error, @Sendable @escaping () -> Void) -> ErrorContent
    // Closure to fetch data asynchronously, potentially throwing errors.
    var fetchData: () async throws -> ViewData
    
    // Initializer to set up the view with state, content, and data-fetching logic.
    public init(
        state: Binding<AsyncLoadingState<ViewData>>,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent,
        @ViewBuilder dataContent: @Sendable @escaping (ViewData) -> DataContent,
        @ViewBuilder errorContent: @escaping (Error, @Sendable @escaping () -> Void) -> ErrorContent = { error, retryAction in
            // Default error view
            ContentUnavailableView(
                label: {
                    Label("Error", systemImage: "xmark")
                        .foregroundStyle(.primary, .red)
                },
                description: {
                    Text(error.localizedDescription)
                },
                actions: {
                    Button("Retry") {
        retryAction()
    }
                    .buttonStyle(.borderedProminent)
                }
            )
        },
        fetchData: @Sendable @escaping () async throws -> ViewData
    ) {
        _state = state
        self.loadingContent = loadingContent
        self.dataContent = dataContent
        self.errorContent = errorContent
        self.fetchData = fetchData
    }
    
    // The main view content.
    public var body: some View {
        // Group to handle different states without affecting layout.
        Group {
            // Switch on the current state to determine what to display.
            switch state {
            case .idle, .loading:
                // Show loading content and disable interaction during loading.
                loadingContent()
                    .disabled(true)
                
            case let .dataLoaded(viewData):
                // Show content with loaded data.
                dataContent(viewData)
                
            case let .error(error):
                // Display the custom error view, passing the retry function.
                //                errorContent(error, retry)
                errorContent(error) {
                    // Retry action to re-fetch data.
                    Task {
                        await retry()
                    }
                }
                
            }
        }
        // Ensure the view fills available space.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Trigger initial data load when the view appears.
        .task { await initialLoad() }
        // Enable pull-to-refresh functionality.
        .refreshable { await performFetchData(showLoading: false) }
    }
    
    // Async function to handle initial data loading when the view appears.
    func initialLoad() async {
        // Only load data if in idle state to avoid redundant fetches.
        guard state == .idle else { return }
        await performFetchData()
    }
    
    // Function to retry data fetching, triggered by the retry button.
    func retry() {
        Task {
            await performFetchData()
        }
    }
    
    // Core function to fetch data and update state.
    private func performFetchData(showLoading: Bool = true) async {
        // Set state to loading with animation if showLoading is true.
        if showLoading { withAnimation { state = .loading } }
        
        do {
            // Fetch data using the provided closure.
            let viewData = try await fetchData()
            // Update state to dataLoaded with animation.
            withAnimation { state = .dataLoaded(viewData) }
        } catch {
            // Update state to error with animation if fetching fails.
            withAnimation { state = .error(error) }
        }
    }
}

// Extension to provide a convenience initializer when using LoadingStateView as the loading content.
public extension AsyncStateView where LoadingContent == LoadingStateView,    ErrorContent == ContentUnavailableView<Label<Text, Image>, Text, Button<Text>> {
    init(
        state: Binding<AsyncLoadingState<ViewData>>,
        @ViewBuilder dataContent: @Sendable @escaping (ViewData) -> DataContent,
        errorContent: @Sendable @escaping (Error, @Sendable @escaping () -> Void) -> ErrorContent = { error, retryAction in
            ContentUnavailableView(
                label: {
                    Label<Text, Image>(
                        title: { Text("Error") },
                        icon: { Image(systemName: "xmark") }
                    )
                },
                description: {
                    Text(error.localizedDescription)
                },
                actions: {
                    
                    Button<Text>(
                        action: {
                            retryAction()
                        },
                        label: { Text("Retry") }
                    ) as Button<Text>
                }
            )
        },
        fetchData: @Sendable @escaping () async throws -> ViewData
    ) {
        _state = state
        self.loadingContent = { LoadingStateView() }
        self.dataContent = dataContent
        self.errorContent = errorContent
        self.fetchData = fetchData
    }
}
