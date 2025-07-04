import Foundation

extension String {
    func fuzzyMatch(_ other: String) -> Bool {
        let pattern = other.lowercased().replacingOccurrences(of: " ", with: "")
        let target = self.lowercased().replacingOccurrences(of: " ", with: "")

        if target.contains(pattern) {
            return true
        }

        var patternIndex = pattern.startIndex
        var targetIndex = target.startIndex

        while patternIndex < pattern.endIndex && targetIndex < target.endIndex {
            if pattern[patternIndex] == target[targetIndex] {
                patternIndex = pattern.index(after: patternIndex)
            }
            targetIndex = target.index(after: targetIndex)
        }

        return patternIndex == pattern.endIndex
    }
}
