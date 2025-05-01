import Foundation

// Represents a single pre-commit hook
struct Hook: Identifiable, Hashable {
    var id: String
    var repo: String
    var rev: String
    var description: String
    var details: String
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(repo)
    }
    
    static func == (lhs: Hook, rhs: Hook) -> Bool {
        return lhs.id == rhs.id && lhs.repo == rhs.repo
    }
}

// Represents a group of related hooks
struct HookGroup: Identifiable {
    var id: String { name }
    var name: String
    var description: String
    var hooks: [Hook]
}

// Configuration for the app
struct Config {
    static let repoURL = "https://github.com/brunogama/pre-commit-configs"
    static let branch = "main"
    static let archiveURL = "\(repoURL)/archive/refs/heads/\(branch).tar.gz"
    static let configFile = ".pre-commit-config.yaml"
    static let scriptsDir = "scripts"
} 