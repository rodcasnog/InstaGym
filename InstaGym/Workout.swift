//
//  Workout.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 25.11.2024.
//

import SwiftData
import Foundation


struct WorkoutUUID: Hashable, Identifiable, Codable {
    let id: UUID
    init(_ uuid: UUID) {
        self.id = uuid
    }
}

@Model
class Workout: Identifiable, Codable {
    @Attribute(.unique) var uuid = UUID()
    var date: Date?
    var duration: Double?
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout) var exercises = [Exercise]()
    var exerciseOrder = [UUID: Double]()
    
    var workoutUUID: WorkoutUUID {
        .init(uuid)
    }
    
    enum CodingKeys: String, CodingKey {
        case date, duration, exercises
    }
    
    init(date: Date? = nil, duration: Double? = nil) {
        self.date = date
        self.duration = duration
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encode(exercises, forKey: .exercises)
    }
    
    var formattedDate: String {
        date?.formatted(date: .abbreviated, time: .omitted) ?? "-"
    }
    
    var formattedDuration: String {
        duration?.formatted() ?? "-"
    }
    
    var bodyParts: [BodyPart] {
        let allBodyParts: [BodyPart] = exercises.map { exercise in
            exercise.exerciseType?.bodyPart ?? .unknown
        }
        return Array(Set(allBodyParts)).sorted()
    }
    
    var formattedBodyParts: String {
        bodyParts.map(\BodyPart.rawValue).joined(separator: ", ")
    }
    
    var formattedExerciseTypeNames: String {
        exercises.map { $0.formattedExerciseTypeName }.joined(separator: ", ")
    }
}
    
extension Workout {
    var exerciseArray: [Exercise] {
        exercises.sorted {
            exerciseOrder[$0.uuid, default: Double(exerciseOrder.count)] < exerciseOrder[$1.uuid, default: Double(exerciseOrder.count)]
        }
    }
    
    func insertExercise(_ exercise: Exercise, at position: Int? = nil) {
        exercises.append(exercise)
        if let position {
            exerciseOrder[exercise.uuid] = Double(position) - 0.5
            resetOrder()
        } else {
            exerciseOrder[exercise.uuid] = Double(exerciseOrder.count)
        }
    }
    
    func moveExercise(_ exercisesToMove: [Exercise], to position: Int) {
        for (i, exerciseToMove) in exercisesToMove.enumerated() {
            exerciseOrder[exerciseToMove.uuid] = Double(position) - Double(i + 1) / Double(exercisesToMove.count + 1)
        }
        resetOrder()
    }
    
    func moveExercise(_ exerciseToMove: Exercise, to position: Int) {
        moveExercise([exerciseToMove], to: position)
    }
    
    func removeExercise(_ exercisesToRemove: [Exercise]) {
        exercises.removeAll { exercisesToRemove.map(\.uuid).contains($0.uuid) }
        for exerciseToRemove in exercisesToRemove {
            if exerciseOrder[exerciseToRemove.uuid] != nil {
                exerciseOrder.removeValue(forKey: exerciseToRemove.uuid)
            }
        }
        resetOrder()
    }
    
    func removeExercise(_ exerciseToRemove: Exercise) {
        removeExercise([exerciseToRemove])
    }
    
    private func resetOrder() {
        for (index, exercise) in exerciseArray.enumerated() {
            exerciseOrder[exercise.uuid] = Double(index)
        }
    }
}

extension Workout {
    static func insertMock(_ context: ModelContext) -> Workout {
        let workout = Workout(date: Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...365), to: .now), duration: Double(Int.random(in: 1...120)))
        for _ in 0..<Int.random(in: 3...6) {
            workout.insertExercise(Exercise.insertMock(context))
        }
        context.insert(workout)
        return workout
    }
}
