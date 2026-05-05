//
//  Untitled.swift
//  Photo Stitch
//
//  Created by TapUniverse Dev9 on 3/7/25.
//

import UIKit

private typealias RemainingRemovalTracker = [Int: Int]

/*
 CollectionDifference Changes are ordered: removals high->low, insertions low->high.
 RemainingRemovalTracker is used to track the position of items left in the collection, but that
 are assumed absent in the offsets provided for later insertions.
 */
private extension RemainingRemovalTracker {
    mutating func addSkippedRemoval(atOffset offset: Int) {
        self[offset] = offset }
    
    mutating func useSkippedRemoval(withOriginalOffset originalOffset: Int) -> Int {
        let currentOffset = removeValue(forKey: originalOffset)!
        removalMade(at: currentOffset)
        return currentOffset }
    
    mutating func removalMade(at offset: Int) {
        forEach({ key, value in
            if value > offset {
                self[key] = value - 1 } })
    }
    
    mutating func insertionMade(at offset: Int) {
        forEach { key, value in
            if value >= offset {
                self[key] = value + 1 } }
    }

    func adjustedInsertion(withOriginalOffset originalOffset: Int) -> Int {
        var adjustedOffset = originalOffset

        values.sorted().forEach { offset in
            if offset <= adjustedOffset {
                adjustedOffset += 1 } }
        
        return adjustedOffset
    }
}

extension CollectionDifference where ChangeElement: Hashable {
    public enum ChangeStep {
        case insert(_ element: ChangeElement, at: Int)
        case remove(_ element: ChangeElement, at: Int)
        case move(_ element: ChangeElement, from: Int, to: Int)
    }
    
    public var steps: [ChangeStep] {
        guard !isEmpty else { return [] }
        
        var steps: [ChangeStep] = []
        var offsetTracker = RemainingRemovalTracker()

        inferringMoves().forEach { change in
            switch change {
            case let .remove(offset, element, associatedWith):
                if associatedWith != nil {
                    offsetTracker.addSkippedRemoval(atOffset: offset)
                } else {
                    steps.append(.remove(element, at: offset))
                    offsetTracker.removalMade(at: offset)
                }

            case let.insert(offset, element, associatedWith):
                if let associatedWith = associatedWith {
                    let from = offsetTracker.useSkippedRemoval(withOriginalOffset: associatedWith)
                    let to = offsetTracker.adjustedInsertion(withOriginalOffset: offset)
                    steps.append(.move(element, from: from, to: to))
                    offsetTracker.insertionMade(at: to)
                } else {
                    let to = offsetTracker.adjustedInsertion(withOriginalOffset: offset)
                    steps.append(.insert(element, at: to))
                    offsetTracker.insertionMade(at: to)
                }
            }
        }

        return steps
    }
}

extension Array where Element: Equatable & Hashable {
    func contains(_ element: Element) -> Bool {
        return contains(where: { $0 == element })
    }
    
    func transformArray(to newArray: [Element], add: ((Element, Int) -> Void)?, remove: ((Int) -> Void)?, move: ((Int, Int) -> Void)?) {
        let changes = newArray.difference(from: self).steps
        
        for change in changes {
            switch change {
            case .remove(_, let index):
                remove?(index)
            case .insert(let element, let index):
                add?(element, index)
            case .move(_, let from, let to):
                move?(from, to)
            }
        }
    }
}

