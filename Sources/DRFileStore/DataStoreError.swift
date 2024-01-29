//
//  DataStoreError.swift
//
//
//  Created by Yannick Jacques on 2024-01-29.
//

import Foundation

/// An enumeration that describes the errors that can be thrown by `DataStore`.
///
/// `DataStoreError` covers a range of errors related to file operations, including issues with file paths, data conversion, and underlying file system errors.
public enum DataStoreError: Error, Equatable {
    /// Indicates that the document directory URL is invalid or could not be found.
    case invalidDocumentDirectoryUrl

    /// Thrown when an object fails to convert to data.
    case dataConversionFailed

    /// Thrown when data fails to convert back to the specified object type.
    case objectConversionFailed

    /// Thrown when the requested file does not exist.
    case fileDoestNotExist

    /// Thrown when there is an error in retrieving data, with an associated underlying error.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case getDataFailed(Error)

    /// Thrown when there is an error in saving data, with an associated underlying error.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case saveFailed(Error)

    /// Thrown when there is an error in deleting a file, with an associated underlying error.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case deletionFailed(Error)

    public static func == (lhs: DataStoreError, rhs: DataStoreError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidDocumentDirectoryUrl, .invalidDocumentDirectoryUrl),
            (.dataConversionFailed, .dataConversionFailed),
            (.objectConversionFailed, .objectConversionFailed),
            (.fileDoestNotExist, .fileDoestNotExist):
            return true
        case (.getDataFailed(_), .getDataFailed(_)),
            (.saveFailed(_), .saveFailed(_)),
            (.deletionFailed(_), .deletionFailed(_)):
            return true
        default:
            return false
        }
    }
}

extension DataStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidDocumentDirectoryUrl:
            return "The document directory URL is invalid or could not be found."

        case .dataConversionFailed:
            return "Failed to convert the object to data."

        case .objectConversionFailed:
            return "Failed to convert data to the specified object type."

        case .fileDoestNotExist:
            return "The requested file does not exist."

        case .getDataFailed(let error):
            return "Failed to retrieve data: \(error.localizedDescription)"

        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"

        case .deletionFailed(let error):
            return "Failed to delete the file: \(error.localizedDescription)"
        }
    }
}
