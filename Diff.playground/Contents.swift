//: Playground - noun: a place where people can play

import UIKit
import Diff

var str = "Hello, playground"
var other = "ello, playground"

/**
   Edit Distance - http://documents.scribd.com/docs/10ro9oowpo1h81pgh1as.pdf
 Assumptions:
    1. A line that occurs once and only once in each file must be the same line (unchanged but possibly moved). This "finds" most lines and thus excludes them from further consideration.
    2. If in each file immediately adjacent to a "found" line pair there are lines identical to each other, these lines must be the same line. Repeated application will "find" sequences of unchanged lines.

 */
func diff<T: Collection>(old: T, new: T) -> EditDistance<T> where T.Iterator.Element: Equatable & Hashable, T.IndexDistance == Int {
    var symbolTable: [T.Iterator.Element: Entry] = [:]

    /// step 1: Tokenize new collection
    var newReferences = [Reference]()
    var counter = 0
    new.forEach {
        switch symbolTable[$0] {
        case .none:
            symbolTable[$0] = Entry(oldCounter: 0, newCounter: 1, oldIndicies: [])
        case .some(let entry):
            symbolTable[$0] = Entry(oldCounter: entry.oldCounter, newCounter: entry.newCounter + 1, oldIndicies: entry.oldIndicies)
        }
        newReferences.append(.pointer(counter))
        counter += 1
    }
    
    // step 2: Tokenize new collection
    var oldReferences = [Reference]()
    counter = 0
    old.forEach {
        switch symbolTable[$0] {
        case .none:
            symbolTable[$0] = Entry(oldCounter: 1, newCounter: 0, oldIndicies: [counter])
        case .some(let value):
            symbolTable[$0] = Entry(oldCounter: value.oldCounter + 1, newCounter: value.newCounter, oldIndicies: value.oldIndicies + [counter])
        }
        oldReferences.append(.pointer(counter))
        counter += 1
    }
    
    // step 3, uses assumption 1
    counter = 0
    new.forEach {
        let symbol = symbolTable[$0]!
        if symbol.oldCounter == 1 && symbol.newCounter == 1 {
            newReferences[counter] = .line(symbol.oldIndicies[0])
            oldReferences[counter] = .line(counter)
        }
        counter += 1
    }
    
    // step 4, uses assumption 2 ascendingly
    counter = 0
    newReferences.forEach {
        switch $0 {
        case let .line(lineNumber):
            let newRef = newReferences[safe: counter + 1]
            let oldRef = oldReferences[safe: lineNumber + 1]
            if newRef == nil && oldRef == nil { break }
            if newReferences[safe: counter + 1] == oldReferences[safe: lineNumber + 1] {
                oldReferences[lineNumber] = .line(counter + 1)
                newReferences[counter + 1] = .line(lineNumber + 1)
            }
        case .pointer:
            break
        }
        counter += 1
    }
    
    // step 5, uses assumption 2 descendingly
    counter = 0
    newReferences.forEach {
        switch $0 {
        case let .line(lineNumber):
            if newReferences[safe: counter - 1] == oldReferences[safe: lineNumber - 1] {
                oldReferences[lineNumber] = .line(counter - 1)
                newReferences[counter - 1] = .line(lineNumber - 1)
            }
        case .pointer:
            break
        }
        counter += 1
    }
    
    print(newReferences)
    
    let d = newReferences.map { ref -> T.Iterator.Element? in
        switch ref {
        case let .line(lineNumber):
            let idx = new.index(new.startIndex, offsetBy: lineNumber)
            return new[safe: idx]
            
        case let .pointer(pointerIndex):
            let idx = old.index(new.startIndex, offsetBy: pointerIndex)
            return nil//new[safe: idx]
        }
    }
    print(d)
    
    return EditDistance(insertions: [], moves: [], deletions: [])
}

struct Entry {
    let oldCounter: Int
    let newCounter: Int
    
    let oldIndicies: [Int]
}

enum Reference {
    case pointer(Int)
    case line(Int)
}

extension Reference: Equatable {
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        switch (lhs, rhs) {
        case (.pointer(let l), .pointer(let r)):
            return l == r
        case (.line(let l), .line(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

// TODO: not sure if this should be called *tokenize*, I liked the sound of the word here
// TODO: test reduce() instead of a for-loop. What are the perf implications?

diff(old: str.characters, new: other.characters)
