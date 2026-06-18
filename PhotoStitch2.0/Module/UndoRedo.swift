//
//  UndoRedo.swift
//  PhotoStitch2.0
//
//  Created by Azuby on 6/18/26.
//

import UIKit

enum UndoRedoError: Error {
    case error(String)
}

/**
 A Handler to handle undo redo of any type built in
 */
@Observable class UndoRedo {
    private var steps: [UndoRedoStep] = []
    private var index: Int = -1
    
    var canUndo: Bool {
        get { index >= 0 }
    }
    
    var canRedo: Bool {
        get { index < steps.count - 1 }
    }
    
    ///```
    ///Add new data will remove all redo available
    ///```
    func add(_ step: UndoRedoStep) {
        steps = Array(steps.prefix(index + 1))
        
        steps.append(step)
        index = index + 1
    }
    
    ///```
    ///Replace new data will remove all redo available
    ///```
    func replace(_ step: UndoRedoStep) {
        steps = Array(steps.prefix(index + 1))
        
        if steps.indices.contains(index) {
            steps[index] = step
        }
    }
    
    func undo() async throws {
        guard canUndo else {
            throw UndoRedoError.error("Can't undo")
        }
        
        guard steps.indices.contains(index) else {
            throw UndoRedoError.error("Undo unknown error")
        }
        
        try await steps[index].undo()
        
        index = index - 1
    }
    
    func redo() async throws {
        guard canRedo else {
            throw UndoRedoError.error("Can't redo")
        }
        
        index = index + 1
        
        guard steps.indices.contains(index) else {
            throw UndoRedoError.error("Redo unknown error")
        }
        
        try await steps[index].redo()
    }
    
    ///```
    ///Remove all datas
    ///```
    func deprecated() {
        steps.removeAll()
        index = -1
    }
}

class UndoRedoStep: Hashable {
    let id = UUID().uuidString
    
    let undo: () async throws -> Void
    let redo: () async throws -> Void
    
    init(undo: @escaping () async throws -> Void, redo: @escaping () async throws -> Void) {
        self.undo = undo
        self.redo = redo
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UndoRedoStep, rhs: UndoRedoStep) -> Bool {
        lhs.id == rhs.id
    }
}
