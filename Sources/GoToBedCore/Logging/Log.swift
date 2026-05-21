import Foundation
import os

/// Centralized `os_log` loggers, one per subsystem (PRD NFR-obs-1).
///
/// Inspect in Console.app by filtering on subsystem `us.endash.GoToBed`.
public enum Log {
    public static let subsystem = "us.endash.GoToBed"

    public static let scheduler = Logger(subsystem: subsystem, category: "scheduler")
    public static let overlay = Logger(subsystem: subsystem, category: "overlay")
    public static let persistence = Logger(subsystem: subsystem, category: "persistence")
    public static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
}
