//
//  ExerciseType.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 25.11.2024.
//

import SwiftData
import Foundation


struct ExerciseTypeUUID: Hashable, Identifiable, Codable {
    let id: UUID
    init(_ uuid: UUID) {
        self.id = uuid
    }
}

enum BodyPart: String, Codable, CaseIterable, Comparable {
    case legs = "Legs"
    case back = "Back"
    case chest = "Chest"
    case triceps = "Triceps"
    case biceps = "Biceps"
    case shoulders = "Shoulders"
    case core = "Core"
    case cardio = "Cardio"
    case unknown = "Unknown"
    
    static var allValidCases: [BodyPart] {
        [.legs, .chest, .back, .triceps, .biceps, .shoulders, .core]
    }
    
    static func < (lhs: BodyPart, rhs: BodyPart) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

@Model
class ExerciseType: Identifiable, Codable {
    @Attribute(.unique) var uuid = UUID()
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .nullify, inverse: \Exercise.exerciseType) private var exercises = [Exercise]()
    var rawBodyPart: String
    var bodyPart: BodyPart {
        set { rawBodyPart = newValue.rawValue }
        get { BodyPart(rawValue: rawBodyPart) ?? .unknown }
    }
    
    var exerciseTypeUUID: ExerciseTypeUUID {
        .init(uuid)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, rawBodyPart
    }
    
    init(_ name: String, bodyPart: BodyPart) {
        self.name = name
        self.rawBodyPart = bodyPart.rawValue
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        rawBodyPart = try container.decode(String.self, forKey: .rawBodyPart)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(rawBodyPart, forKey: .rawBodyPart)
    }
    
    static func fetch(withName name: String, using context: ModelContext) -> ExerciseType? {
        let request = FetchDescriptor<ExerciseType>(predicate: #Predicate { $0.name == name })
        return try? context.fetch(request).first
    }
    
    static func fetch(withUUID uuid: UUID, using context: ModelContext) -> ExerciseType? {
        let request = FetchDescriptor<ExerciseType>(predicate: #Predicate { $0.uuid == uuid })
        return try? context.fetch(request).first
    }
    
    static func fetchOrCreate(withName name: String, withBodyPart bodyPart: BodyPart? = nil, using context: ModelContext) throws -> ExerciseType {
        if let existing = fetch(withName: name, using: context) {
            return existing
        } else {
            if let bodyPart {
                let newExerciseType = ExerciseType(name, bodyPart: bodyPart)
                context.insert(newExerciseType)
                try context.save()
                return newExerciseType
            } else {
                throw NSError(domain: "ExerciseType", code: 0, userInfo: ["Cause": "No body part specified"])
            }
        }
    }
    
    static let REFERENCE_EXERCISE_DICT: [BodyPart: [String]] = [
        .legs: ["Squats", "Leg Press", "Leg extension", "Leg Curl", "Lying leg curl", "Calf Raise", "Lunges", "Smith machine squats", "Smith machine lunges", "Hip thrust", "Glute bridge", "Hip adductor", "Hip abductor"],
        .back: ["Barbell row", "Seated machine row", "Dumbbell row", "Pull-up", "Pull-down", "T-row", "Deadlift", "Sumo deadlift", "Dumbbell deadlift", "Romanian deadlift"],
        .chest: ["Barbell bench press", "Dumbbell bench press", "Incline bench press", "Incline dumbbell bench press", "Decline barbell bench press", "Decline dumbbell bench press", "Chest fly", "Close grip bench press", "Push up"],
        .triceps: ["Triceps cable push-down", "Triceps dumbbell extension", "Triceps cable extension", "Overhead triceps dumbbell extension", "Overhead triceps cable extension", "Skull crusher"],
        .biceps: ["Standing biceps cable curl", "Standing biceps dumbbell curl", "Seated biceps dumbbell curl", "Barbell curl", "Preacher curl", "Hammer curl", "Concentration curl"],
        .shoulders: ["Barbell overhead press", "Standing dumbbell shoulder press", "Seated dumbbell shoulder press", "Seated barbell shoulder press", "Shoulder machine press", "Dumbbell lateral raise", "Cable lateral raise", "Dumbbell front raise", "Rear delt fly", "Upright row", "Arnold press"],
        .core: ["Plank", "Side plank", "Crunches", "Dead bug", "Bicycle crunch"],
        .cardio: ["Treadmill","Cycling", "Steps"],
        .unknown: ["Unknown"]
    ]
    
    static func insertDefaultTypes(_ context: ModelContext) {
        for bodyPart in BodyPart.allValidCases {
            for exerciseTypeName in REFERENCE_EXERCISE_DICT[bodyPart]! {
                try! fetchOrCreate(withName: exerciseTypeName, withBodyPart: bodyPart, using: context)
            }
        }
    }
    
    static func insertMock(_ context: ModelContext) -> ExerciseType {
        let bodyPart = BodyPart.allValidCases.randomElement()!
        let exerciseTypeName = REFERENCE_EXERCISE_DICT[bodyPart]!.randomElement()!
        let exercieType = try! fetchOrCreate(withName: exerciseTypeName, withBodyPart: bodyPart, using: context)
        return exercieType
    }
}
