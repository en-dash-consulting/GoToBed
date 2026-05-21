import Foundation

/// Loads and saves `AppState` as human-readable JSON (PRD §5.6, NFR-persist).
///
/// On any decode failure the store degrades gracefully to defaults and logs,
/// rather than crashing or losing the user's ability to launch (NFR-persist-2).
public final class AppStatePersistence {
    public let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// - Parameter fileURL: where to store state. Defaults to
    ///   `Application Support/GoToBed/state.json`. Injectable for tests.
    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder = enc
        self.decoder = JSONDecoder()
    }

    public static func defaultFileURL() -> URL {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? FileManager.default.temporaryDirectory
        return base
            .appendingPathComponent("GoToBed", isDirectory: true)
            .appendingPathComponent("state.json", isDirectory: false)
    }

    /// Reads state from disk. Returns `.empty` when the file is missing, and
    /// logs + returns `.empty` when it exists but cannot be decoded.
    public func load() -> AppState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .empty
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(AppState.self, from: data)
        } catch {
            Log.persistence.error(
                "Failed to decode \(self.fileURL.lastPathComponent, privacy: .public); falling back to defaults: \(String(describing: error), privacy: .public)"
            )
            return .empty
        }
    }

    /// Atomically writes state to disk, creating the containing directory.
    public func save(_ state: AppState) throws {
        let dir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }
}
