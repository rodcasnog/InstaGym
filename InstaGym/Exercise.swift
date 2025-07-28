//
//  Exercise.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftData
import Foundation


struct ExerciseUUID: Hashable, Identifiable, Codable {
    let id: UUID
    init(_ uuid: UUID) {
        self.id = uuid
    }
}

@Model
class Exercise: Identifiable, Codable {
    @Attribute(.unique) var uuid = UUID()
    @Relationship(deleteRule: .nullify) var workout: Workout?
    @Relationship(deleteRule: .nullify) var exerciseType: ExerciseType?
    @Relationship(deleteRule: .cascade) private var sets = [ExerciseSet]()
    var duration: Double? = nil
    var comment: String? = nil
    var setOrder = [UUID: Double]()
    
    var exerciseUUID: ExerciseUUID {
        .init(uuid)
    }
    
    var formattedExerciseTypeName: String {
        exerciseType?.name ?? "New exercise"
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseType, sets, duration, comment
    }
    
    init(_ exercise: Exercise?) {
        if let exercise {
            self.exerciseType = exercise.exerciseType
            self.sets = exercise.sets.map(ExerciseSet.init)
            self.duration = exercise.duration
            self.comment = exercise.comment
        }
    }
    
    init(duration: Double? = nil, comment: String? = nil) {
        self.duration = duration
        self.comment = comment
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exerciseType = try container.decodeIfPresent(ExerciseType.self, forKey: .exerciseType)
        self.sets = try container.decode([ExerciseSet].self, forKey: .sets)
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(exerciseType, forKey: .exerciseType)
        try container.encode(sets, forKey: .sets)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(comment, forKey: .comment)
    }
}

extension Exercise {
    
    var setArray: [ExerciseSet] {
        sets.sorted {
            setOrder[$0.uuid, default: Double(setOrder.count)] < setOrder[$1.uuid, default: Double(setOrder.count)]
        }
    }
    
    func insertSet(_ newSet: ExerciseSet, at position: Int? = nil) {
        sets.append(newSet)
        if let position {
            setOrder[newSet.uuid] = Double(position) - 0.5
            resetOrder()
        } else {
            setOrder[newSet.uuid] = Double(setOrder.count)
        }
    }
    
    func moveSet(_ setsToMove: [ExerciseSet], to position: Int) {
        for (i, setToMove) in setsToMove.enumerated() {
            setOrder[setToMove.uuid] = Double(position) - Double(i + 1) / Double(setsToMove.count + 1)
        }
        resetOrder()
    }
    
    func moveSet(_ setToMove: ExerciseSet, to position: Int) {
        moveSet([setToMove], to: position)
    }
    
    func removeSet(_ setsToRemove: [ExerciseSet]) {
        sets.removeAll { setsToRemove.map(\.uuid).contains($0.uuid) }
        for setToRemove in setsToRemove {
            if setOrder[setToRemove.uuid] != nil {
                setOrder.removeValue(forKey: setToRemove.uuid)
            }
        }
        resetOrder()
    }
    
    func removeSet(_ setToRemove: ExerciseSet) {
        removeSet([setToRemove])
    }
    
    private func resetOrder() {
        for (index, currentSet) in setArray.enumerated() {
            setOrder[currentSet.uuid] = Double(index)
        }
    }
}

extension Exercise {
    static func insertMock(_ context: ModelContext) -> Exercise {
        let exercise = Exercise(duration: Double(Int.random(in: 1...20)), comment: "Random comment")
        for _ in 0..<Int.random(in: 3...5) {
            exercise.insertSet(ExerciseSet.getMock())
        }
        exercise.exerciseType = ExerciseType.insertMock(context)
        context.insert(exercise)
        return exercise
    }
}
