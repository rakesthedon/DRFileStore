//
//  DataStoreTests.swift
//  
//
//  Created by Yannick Jacques on 2024-01-28.
//

import XCTest
import DRFileStore

final class DataStoreTests: XCTestCase {

    private var filemanager: TestFilemanager!
    private var store: DataStore!

    override func setUp() {
        super.setUp()
        filemanager = TestFilemanager()
        store = DataStore(filemanager: filemanager)

        filemanager.reset()
    }

    func testStoreAndRetrieveData() throws {
        let message = "Hello World!"

        let url = try store.save(object: message, filename: "message.txt")
        let retrievedMessage: String = try store.get(objectAt: url)

        XCTAssertEqual(message, retrievedMessage)
    }

    func testRetrivingInvalidFileShouldThrow() throws {
        let filename = UUID().uuidString

        do {
            let _: String = try store.get(objectAt: filename)
            XCTFail()
        } catch {
            XCTAssert(error is DataStoreError)
        }
    }

    func testFileManagerFailureWhenStoringFile() {
        let message = "Hello World"
        filemanager.enableDocumentFailure()

        do {
            _ = try store.save(object: message, filename: "message\(UUID().uuidString).txt")
            XCTFail()
        } catch {
            XCTAssert(error is DataStoreError)
        }
    }

    func testFileManagerFailureWhenDeletingFile() throws {
        let message = "Hello World!"
        filemanager.enableForceRemoveItemToFail()


        let url = try store.save(object: message, filename: "message\(UUID().uuidString).txt")
        XCTAssertThrowsError(try store.delete(objectAt: url)) { error in
            XCTAssertTrue(error is DataStoreError)
            switch error as? DataStoreError {
            case .deletionFailed:
                return
            default:
                XCTFail("Invalid Error Type")
            }
        }
    }

    func testInvalidDataConvertibleTypeSave() {
        XCTAssertThrowsError(try store.save(object: InvalidDataConvertible(), filename: "InvalidData-\(UUID().uuidString)")) { error in
            XCTAssertEqual(error as? DataStoreError, .dataConversionFailed)
        }
    }

    func testFileExistButDataIsInvalid() {
        let filename = "fakeExistingFile - \(UUID().uuidString)"
        filemanager.enableForceFileDoesExistToSucceed()

        do {
            let _ : String = try store.get(objectAt: filename) }
        catch DataStoreError.getDataFailed(_) {
            return
        } catch {
            XCTFail("Invalid Error Message \(error.localizedDescription)")
        }
    }
}

extension String: DataConvertible {
    public func toData() -> Data? {
        data(using: .utf8)
    }
    
    public static func fromData(_ data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }
}

private struct InvalidDataConvertible: DataConvertible {
    func toData() -> Data? {
        return nil
    }

    static func fromData(_ data: Data) -> InvalidDataConvertible? {
        return InvalidDataConvertible()
    }
}

private class TestFilemanager: FileManager {

    private var forceDocumentUrlCallsToFail = false
    private var forceRemoveItemToFail = false
    private var forceDoesExistSuccess = false

    private let realFileManager: FileManager = .default

    func enableDocumentFailure() {
        forceDocumentUrlCallsToFail = true
    }

    func disableDocumentFailure() {
        forceDocumentUrlCallsToFail = false
    }

    func enableForceRemoveItemToFail() {
        forceRemoveItemToFail = true
    }

    func disableForceRemoveItemToFail() {
        forceRemoveItemToFail = false
    }

    func enableForceFileDoesExistToSucceed() {
        forceDoesExistSuccess = true
    }

    func disableForceFileDoesExistToSucceed() {
        forceDoesExistSuccess = false
    }

    func reset() {
        disableDocumentFailure()
        disableForceRemoveItemToFail()
        disableForceFileDoesExistToSucceed()
    }

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        guard !forceDocumentUrlCallsToFail else { return [] }

        return realFileManager.urls(for: directory, in: domainMask)
    }

    override func removeItem(at URL: URL) throws {
        guard !forceRemoveItemToFail else { throw NSError(domain: "DataStoreTest", code: 500) }

        return try realFileManager.removeItem(at: URL)
    }

    override func fileExists(atPath path: String) -> Bool {
        return forceDoesExistSuccess || realFileManager.fileExists(atPath: path)
    }
}
