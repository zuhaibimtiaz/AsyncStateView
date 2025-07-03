//
//  AsyncLoadingState.swift
//  AsyncStateView
//
//  Created by Zuhaib Imtiaz on 7/3/25.
//

import SwiftUI

// Enum to represent different states of asynchronous data loading.
public enum AsyncLoadingState<Value> {
    // Initial state before any loading has started.
    case idle
    // State when data is being fetched.
    case loading
    // State when data is successfully loaded, holding the value.
    case dataLoaded(_ value: Value)
    // State when an error occurs, holding the error.
    case error(_ error: Error)
    
    // Computed property to get the state type as a string for debugging or logging.
    public var typeName: String {
        switch self {
        case .idle: "idle"
        case .loading: "loading"
        case .dataLoaded: "dataLoaded"
        case .error: "error"
        }
    }
    
    // Computed property to extract the loaded value, if available.
    public var value: Value? {
        guard case let .dataLoaded(value) = self else { return nil }
        return value
    }
    
    // Computed property to extract the error, if available.
    public var error: Error? {
        guard case let .error(error) = self else { return nil }
        return error
    }
}

// Extension to make AsyncLoadingState equatable when its Value type is equatable.
extension AsyncLoadingState: Equatable where Value: Equatable {
    // Custom equality comparison for the enum cases.
    public static func == (
        lhs: AsyncLoadingState<Value>,
        rhs: AsyncLoadingState<Value>
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
            (.loading, .loading):
            return true
        case let (.dataLoaded(lhsValue), .dataLoaded(rhsValue)):
            // Compare values if both states are dataLoaded.
            return lhsValue == rhsValue
        case let (.error(lhsError), .error(rhsError)):
            // Compare errors as NSError for consistent equality checking.
            return (lhsError as NSError) == (rhsError as NSError)
        default:
            // Different states are not equal.
            return false
        }
    }
}
