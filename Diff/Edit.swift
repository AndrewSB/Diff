//
//  EditDistance.swift
//  Diff
//
//  Created by Andrew Breckenridge on 10/16/16.
//  Copyright © 2016 Andrew Breckenridge. All rights reserved.
//

import Foundation

public struct Edit<T: Equatable> {
    public let operation: EditOperation
    public let value: T
    public let destination: Int    
}

public enum EditOperation {
    case insertion
    case deletion
    case move(origin: Int)
}
