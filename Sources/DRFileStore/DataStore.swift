//
//  DataStore.swift
//  DRFileStore
//
//  Created by Yannick Jacques on 2024-01-28.
//

import Foundation

/// `DataStore` is a class designed for managing file storage in iOS applications.
/// It provides functionalities to save, retrieve, and delete objects that conform to the `DataConvertible` protocol.
///
/// To use `DataStore`, create an instance by providing a `FileManager`.
/// After initialization, you can use its methods to perform file operations such as saving, retrieving, and deleting data.
///
/// ```
/// let dataStore = DataStore(filemanager: FileManager.default)
/// let myObject = "Hello, World!"
/// do {
///     let fileURL = try dataStore.save(object: myObject, filename: "greeting.txt")
///     let retrievedObject: String = try dataStore.get(objectAt: "greeting.txt")
///     print(retrievedObject) // Prints "Hello, World!"
///     try dataStore.delete(objectAt: "greeting.txt")
/// } catch {
///     print("An error occurred: \(error)")
/// }
/// ```
public class DataStore {

    private let filemanager: FileManager

    /// Initializes a new `DataStore` instance with the specified `FileManager`.
    /// - Parameter filemanager: The `FileManager` instance to use for file operations.
    public init(filemanager: FileManager) {
        self.filemanager = filemanager
    }

    /// Saves an object that conforms to `DataConvertible` to the specified file.
    ///
    /// This method attempts to convert the object into `Data` and write it to a file in the document directory.
    /// - Parameters:
    ///   - object: The object to save. It must conform to the `DataConvertible` protocol.
    ///   - filename: The name of the file to save the object to.
    /// - Returns: The URL where the object was saved.
    /// - Throws: An error of type `DataStoreError` if the save operation fails.
    public func save<T: DataConvertible>(object: T, filename: String) throws -> URL {
        guard let data = object.toData() else { throw DataStoreError.dataConversionFailed }

        let documentUrl = try getDocumentsDirectory().appendingPathComponent(filename, isDirectory: false)

        do {
            try data.write(to: documentUrl, options: [.atomic])
            return documentUrl
        } catch {
            throw DataStoreError.saveFailed(error)
        }
    }

    /// Retrieves an object of the specified type from a file.
    ///
    /// This method reads data from the specified file and attempts to convert it back into the object of the specified type.
    /// - Parameter filename: The name of the file to retrieve the object from.
    /// - Returns: An object of the specified type.
    /// - Throws: An error of type `DataStoreError` if the retrieval operation fails.
    public func get<T: DataConvertible>(objectAt filename: String) throws -> T {
        let url = try getDocumentsDirectory().appendingPathComponent(filename, isDirectory: false)
        return try get(objectAt: url)
    }

    /// Retrieves an object of the specified type from a given URL.
    ///
    /// Similar to `get(objectAt:)`, but retrieves the object from a specific URL rather than a filename.
    /// - Parameter url: The URL of the file to retrieve the object from.
    /// - Returns: An object of the specified type.
    /// - Throws: An error of type `DataStoreError` if the retrieval operation fails.
    public func get<T: DataConvertible>(objectAt url: URL) throws -> T {
        guard
            let path = url.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            filemanager.fileExists(atPath: path) 
        else { throw DataStoreError.fileDoestNotExist }

        do {
            let data = try Data(contentsOf: url)

            guard let object = T.fromData(data) else { throw DataStoreError.objectConversionFailed }

            return object
        } catch {
            throw DataStoreError.getDataFailed(error)
        }
    }

    /// Deletes the file at the specified filename.
    ///
    /// This method removes the file with the given name from the document directory.
    /// - Parameter filename: The name of the file to delete.
    /// - Throws: An error of type `DataStoreError` if the deletion operation fails.
    public func delete(objectAt filename: String) throws {
        let documentUrl = try getDocumentsDirectory().appendingPathComponent(filename)
        try delete(objectAt: documentUrl)
    }

    /// Deletes the file at the specified URL.
    ///
    /// Similar to `delete(objectAt:)`, but deletes the file at a specific URL rather than a filename.
    /// - Parameter url: The URL of the file to delete.
    /// - Throws: An error of type `DataStoreError` if the deletion operation fails.
    public func delete(objectAt url: URL) throws {
        do {
            try filemanager.removeItem(at: url)
        } catch {
            throw DataStoreError.deletionFailed(error)
        }
    }
}

// MARK: - Private Helper Methods
private extension DataStore {

    /// Retrieves the URL for the documents directory.
    ///
    /// This method returns the URL for the documents directory where files are stored.
    /// - Throws: An error of type `DataStoreError.invalidDocumentDirectoryUrl` if the URL cannot be determined.
    func getDocumentsDirectory() throws -> URL {
        guard let documentUrl = filemanager.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw DataStoreError.invalidDocumentDirectoryUrl }

        return documentUrl
    }
}
