# DRFileStore

DRFileStore is a Swift library for efficiently managing file storage in iOS applications. It simplifies the process of saving, retrieving, and deleting data in the file system. This library is ideal for iOS developers looking for an easy way to handle file operations with Swift.

## Features

- Save and retrieve any objects conforming to the `DataConvertible` protocol.
- Handle file operations with built-in error handling.
- Lightweight and easy to integrate into any iOS project.

## Installation
### Swift Package Manager
#### Via Xcode
1. Go to `File > Add Packages` 
2. Search the DRFileStorePackage by searching in the textfield: `https://github.com/rakesthedon/DRFileStore`
3. Select the version you want to use

## Usage

### Initializing DataStore

```swift
import DRFileStore

let dataStore = DataStore(filemanager: FileManager.default)
```

### Saving Data

```swift
let myObject = "Hello, World!"
do {
    let fileURL = try dataStore.save(object: myObject, filename: "greeting.txt")
    print("File saved at: \(fileURL)")
} catch {
    print("An error occurred: \(error)")
}
```

### Retrieving Data

```swift
do {
    let retrievedObject: String = try dataStore.get(objectAt: "greeting.txt")
    print("Retrieved Object: \(retrievedObject)")
} catch {
    print("An error occurred: \(error)")
}
```

### Deleting Data

```swift
do {
    try dataStore.delete(objectAt: "greeting.txt")
    print("File deleted successfully")
} catch {
    print("An error occurred: \(error)")
}
```

## DataStoreError

`DataStoreError` enum is used to handle various errors that can occur during file operations.

- `.invalidDocumentDirectoryUrl`: Document directory URL is invalid.
- `.dataConversionFailed`: Object to data conversion failed.
- `.objectConversionFailed`: Data to object conversion failed.
- `.fileDoestNotExist`: File does not exist.
- `.getDataFailed(Error)`: Error occurred while retrieving data.
- `.saveFailed(Error)`: Error occurred while saving data.
- `.deletionFailed(Error)`: Error occurred while deleting a file.

## Contributing

Contributions to the DRFileStore project are welcome. Feel free to submit pull requests or create issues for bugs and feature requests.

## License

DRFileStore is released under the MIT License. See the LICENSE file for more information.
