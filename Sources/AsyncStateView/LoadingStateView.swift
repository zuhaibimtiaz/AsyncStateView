//
//  LoadingStateView.swift
//  AsyncStateView
//
//  Created by Zuhaib Imtiaz on 7/3/25.
//

import SwiftUI

// A SwiftUI view that displays a loading indicator with customizable visibility and title.
public struct LoadingStateView: View {
    // State variable to control whether the progress indicator is shown.
    @State var showProgress: Bool
    // State variable for the loading title text.
    @State var title: String
    
    // Initializer with default values for showProgress and title.
    public init(showProgress: Bool = false, title: String = "Loading...") {
        self.showProgress = showProgress
        self.title = title
    }
    
    // The main view content.
    public var body: some View {
        // Vertical stack to center content.
        VStack {
            // Conditionally show the loading indicator and title if showProgress is true.
            if showProgress {
                VStack {
                    // Built-in SwiftUI circular progress indicator.
                    ProgressView()
                    // Display the loading title with secondary text color.
                    Text(title)
                        .foregroundStyle(.secondary)
                }
                // Add padding around the loading content.
                .padding(12)
            } else {
                // Placeholder view when not loading, maintaining layout size.
                Color.clear
                    .frame(width: 100, height: 80)
            }
        }
        // Ensure minimum dimensions for the view.
        .frame(minWidth: 100, minHeight: 80)
        // Run toggleProgress when the view appears.
        .task { await toggleProgress() }
    }
    
    // Async function to toggle the progress indicator after a 1-second delay.
    func toggleProgress() async {
        // Exit if progress is already shown to avoid unnecessary updates.
        guard !showProgress else { return }
        
        do {
            // Simulate a delay (e.g., for loading animation).
            try await Task.sleep(for: .seconds(1))
            // Animate the toggle of showProgress state.
            withAnimation { showProgress.toggle() }
        } catch {
            // Handle potential errors from Task.sleep (e.g., task cancellation).
        }
    }
}

#Preview {
    VStack {
        LoadingStateView()
            .border(Color.red)
        
        LoadingStateView(showProgress: true)
            .border(Color.blue)
    }
}
