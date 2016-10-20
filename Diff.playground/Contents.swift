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
        .filter { entry in
            entry.occurrencesInNew == 1 && entry.occurrencesInOld == 1
        }
        .enumerated()
        .forEach { index, entry in
            assert(entry.indicesOfOccurrencesInOld.count == 1)
            let oldIndex = entry.indicesOfOccurrencesInOld.last!
            
            newReferences[index] = .otherCollection(oldIndex)
            oldReferences[index] = .otherCollection(index)
        }
}

func step4<T: Collection>(new: T, symbolTable: inout [T.Iterator.Element: TableEntry], newReferences: inout [Reference<T>], oldReferences: inout [Reference<T>]) {
    newReferences.enumerated().forEach { i, reference in
        
        // if newRef[i] points to the an oldCollection index (j)
        if case .otherCollection(let j) = reference {
            
            // and newRef[i + 1] points to the same table entry as the oldRef[j + 1]
            if let iPlusOneEntry = newReferences[safe: i + 1],
                let jPlusOneEntry = oldReferences[safe: j + 1],
                case .table(_) = iPlusOneEntry,
                case .table(_) = jPlusOneEntry,
                iPlusOneEntry == jPlusOneEntry {
            
                // then set newRef[i + 1] to .otherCollection(j + 1), and oldRef[j + 1] to .otherCollection(i + 1)
                newReferences[i + 1] = .otherCollection(j + 1)
                oldReferences[j + 1] = .otherCollection(i + 1)
            }
        }
    }
}

func step5<T: Collection>(new: T, symbolTable: inout [T.Iterator.Element: TableEntry], newReferences: inout [Reference<T>], oldReferences: inout [Reference<T>]) {
    newReferences.enumerated().forEach { i, reference in
        // if newRef[i] points to the an oldCollection index (j)
        if case .otherCollection(let j) = reference {
            
            // and newRef[i - 1] points to the same table entry as the oldRef[j - 1]
            if let iMinusOneEntry = newReferences[safe: i - 1],
                let jMinusOneEntry = oldReferences[safe: j - 1],
                case .table(_) = iMinusOneEntry,
                case .table(_) = jMinusOneEntry,
                iMinusOneEntry == jMinusOneEntry {
            
                // then set newRef[i - 1] to .otherCollection(j - 1), and oldRef[j - 1] to .otherCollection(i - 1)
                newReferences[i + 1] = .otherCollection(j - 1)
                oldReferences[j + 1] = .otherCollection(i - 1)
                
            }
            
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
    
    step4(new: new, symbolTable: &symbolTable, newReferences: &newReferences, oldReferences: &oldReferences)
    
    step5(new: new, symbolTable: &symbolTable, newReferences: &newReferences, oldReferences: &oldReferences)
    
    print(newReferences)
    
    return []
}

_ = diff(old: ["🕵️‍♀️", "🦁", "🐲"], new: ["🐲", "🦁", "🌿"])

// TODO: test reduce() instead of a for-loop. What are the perf implications?
