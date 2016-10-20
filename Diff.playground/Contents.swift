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
func diff<T: Collection>(old: T, new: T) -> [Edit<T>] where T.Iterator.Element: Equatable & Hashable, T.IndexDistance == Int {
    
    var symbolTable: [T.Iterator.Element: Entry] = [:]
    var newReferences = [Reference<T>]()
    var oldReferences = [Reference<T>]()
    
    
    var counter = 0
    new.forEach {
        switch symbolTable[$0] {
        case .none:
            symbolTable[$0] = Entry(occurrencesInOld: 0, occurrencesInNew: 1, indicesOfOccurrencesInOld: [])
        case .some(let entry):
            symbolTable[$0] = Entry(occurrencesInOld: entry.occurrencesInOld, occurrencesInNew: entry.occurrencesInNew + 1, indicesOfOccurrencesInOld: entry.indicesOfOccurrencesInOld)
        }
        newReferences.append(.pointer(counter))
        counter += 1
    }
    
    // step 2: Tokenize new collection
    var oldReferences = [Reference<T>]()
    counter = 0
    old.forEach {
        switch symbolTable[$0] {
        case .none:
            symbolTable[$0] = Entry(occurrencesInOld: 1, occurrencesInNew: 0, indicesOfOccurrencesInOld: [counter])
        case .some(let value):
            symbolTable[$0] = Entry(occurrencesInOld: value.occurrencesInOld + 1, occurrencesInNew: value.occurrencesInNew, indicesOfOccurrencesInOld: value.indicesOfOccurrencesInOld + [counter])
        }
        oldReferences.append(.pointer(counter))
        counter += 1
    }
    
    // step 3, uses assumption 1
    counter = 0
    new.forEach {
        let symbol = symbolTable[$0]!
        if symbol.occurrencesInOld == 1 && symbol.occurrencesInNew == 1 {
            newReferences[counter] = .line(symbol.indicesOfOccurrencesInOld.first!)
            oldReferences[symbol.indicesOfOccurrencesInOld.first!] = .line(counter)
        }
        counter += 1
    }
    
    // step 4, uses assumption 2 ascendingly
    counter = 0
    new.forEach { _ in
        let assertions = [
            newReferences[safe: counter] != nil,
            newReferences[safe: counter + 1] != nil,
            newReferences[counter] == oldReferences[counter],
            newReferences[counter + 1] == oldReferences[counter]
        ]
        
        let allTrue = assertions.reduce(true) { $0 && $1 }
        if allTrue {
            newReferences[counter + 1] = .line(counter)
        }
    }
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
    
    return []
}

struct Entry {
    let occurrencesInOld: Int
    let occurrencesInNew: Int
    
    let indicesOfOccurrencesInOld: [Int]
}


// TODO: test reduce() instead of a for-loop. What are the perf implications?

diff(old: str.characters, new: other.characters)
