import Foundation

/// A path to a file with validation
public final class FilePath {
    private let value: String
    
    public init(_ path: String) {
        self.value = path
    }
    
    public var path: String {
        return value
    }
    
    public func exists(using fileManager: FileManager = .default) -> Bool {
        return fileManager.fileExists(atPath: value)
    }
} 