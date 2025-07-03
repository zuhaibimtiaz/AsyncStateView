//
//  ExampleView.swift
//  AsyncStateView
//
//  Created by Zuhaib Imtiaz on 7/3/25.
//

import SwiftUI

private struct ExampleView: View {
    @State var state: AsyncLoadingState<String> = .idle
    @State var secondsDelay: Int = 3
    
    var body: some View {
        VStack {
            AsyncStateView(
                state: $state,
                loadingContent: {
                    Text("asdasd")
                },
                dataContent: { text in
                    Text(text)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray)
                },
                errorContent: { error, retryAction in
                    VStack {
                        Text("Failed to load: \(error.localizedDescription)")
                        Button("Retry") {
                            retryAction()
                        }
                    }
                },
                fetchData: {
                    try await Task.sleep(for: .seconds(secondsDelay))
                    return "Sample Text"
                }
            )
            
            VStack {
                Text(state.typeName)
                
                HStack {
                    Button("Idle", action: { set(.idle) })
                    Button("Loading", action: { set(.loading) })
                    Button("Data", action: { set(.dataLoaded("Sample Text")) })
                    Button("Error", action: { set(.error(CancellationError())) })
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    func set(_ newState: AsyncLoadingState<String>) {
        withAnimation { state = newState }
    }
}

#Preview {
    ExampleView()
}
