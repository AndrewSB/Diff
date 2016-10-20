import Foundation

/**
 TODO:
    When this is moved out of the playground, this should be an internal type for the Diff module, NOT PUBLIC
 */
public enum Reference<T: Collection> where T.Iterator.Element: Equatable, T.IndexDistance == Int {
    public typealias Index = Int
    
    case table(T.Iterator.Element)
    case otherCollection(Index)
}

extension Reference: Equatable {
    public static func == (lhs: Reference, rhs: Reference) -> Bool {
        switch (lhs, rhs) {
        case (.table(let l), .table(let r)):
            return l == r
        case (.otherCollection(let l), .otherCollection(let r)):
            return l == r
        default:
            return false
        }
    }
}
