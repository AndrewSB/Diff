//: Playground - noun: a place where people can play
import Foundation
import Diff

struct TableEntry {
    var occurrencesInOld: Int               = 0
    var occurrencesInNew: Int               = 0
    
    var indicesOfOccurrencesInOld: [Int]    = []
}

func step1<T: Collection>(new: T, symbolTable: inout [T.Iterator.Element: TableEntry], newReferences: inout [Reference<T>]) {
    new.forEach { element in
        var tableEntry = symbolTable[element] ?? TableEntry()
        
        tableEntry.occurrencesInNew += 1
        symbolTable[element] = tableEntry
        
        newReferences.append(.table(element))
    }

    print(symbolTable)
}

func step2<T: Collection>(old: T, symbolTable: inout [T.Iterator.Element: TableEntry], oldReferences: inout [Reference<T>]) {
    old.enumerated().forEach { index, element in
        var tableEntry = symbolTable[element] ?? TableEntry()

        tableEntry.occurrencesInOld += 1
        tableEntry.indicesOfOccurrencesInOld.append(index)
        symbolTable[element] = tableEntry
    
        oldReferences.append(.table(element))
    }
}

func step3<T: Collection>(new: T, symbolTable: inout [T.Iterator.Element: TableEntry], newReferences: inout [Reference<T>], oldReferences: inout [Reference<T>]) {
    new
        .map { symbolTable[$0]! }
        .enumerated()
        .forEach { index, entry in
            print("\(index) \(entry.indicesOfOccurrencesInOld)")

            if let oldIndex = entry.indicesOfOccurrencesInOld.last {
                newReferences[index] = .otherCollection(oldIndex)
                oldReferences[index] = .otherCollection(index)
            }
        }
}

/**
   Edit Distance - http://documents.scribd.com/docs/10ro9oowpo1h81pgh1as.pdf
 Assumptions:
    1. A line that occurs once and only once in each file must be the same line (unchanged but possibly moved). This "finds" most lines and thus excludes them from further consideration.
    2. If in each file immediately adjacent to a "found" line pair there are lines identical to each other, these lines must be the same line. Repeated application will "find" sequences of unchanged lines.

 */
func diff<T: Collection>(old: T, new: T) -> [Edit<T.Iterator.Element>] where T.Iterator.Element: Equatable & Hashable, T.IndexDistance == Int {
    
    var symbolTable: [T.Iterator.Element: TableEntry] = [:]
    var newReferences = [Reference<T>]()
    var oldReferences = [Reference<T>]()
    
    step1(new: new, symbolTable: &symbolTable, newReferences: &newReferences)
    
    step2(old: old, symbolTable: &symbolTable, oldReferences: &oldReferences)
    
    step3(new: new, symbolTable: &symbolTable, newReferences: &newReferences, oldReferences: &oldReferences)

    print(oldReferences)
    print(newReferences)
    
    return []
}

_ = diff(old: ["🕵️‍♀️", "🦁", "🐲"], new: ["🕵️‍♀️", "🦁", "🐲", "🐲", "s"])

// TODO: test reduce() instead of a for-loop. What are the perf implications?
