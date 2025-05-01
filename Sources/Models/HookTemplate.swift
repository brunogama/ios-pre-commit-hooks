import Foundation

/// Represents a hook template from the hooks-templates directory
struct HookTemplate: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var directory: String
    var description: String
    var configuration: String
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(directory)
    }
    
    static func == (lhs: HookTemplate, rhs: HookTemplate) -> Bool {
        return lhs.name == rhs.name && lhs.directory == rhs.directory
    }
} 