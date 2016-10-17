//
//  EditDistance.swift
//  Diff
//
//  Created by Andrew Breckenridge on 10/16/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import Foundation

public struct EditDistance<T> {
    public let insertions: [T]
    public let moves: [T]
    public let deletions: [T]
    
    public init(insertions: [T], moves: [T], deletions: [T]) {
        self.insertions = insertions
        self.moves = moves
        self.deletions = deletions
    }
}
