//
//  ExerciseSet.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftData
import Foundation



struct ExerciseSetUUID: Hashable, Identifiable, Codable {
    let id: UUID
    init(_ uuid: UUID) {
        self.id = uuid
    }
}

@Model
class ExerciseSet: Codable, Identifiable {
    @Attribute(.unique) var uuid = UUID()
    var weight: Double? = nil
    var reps: Double? = nil
    var restTime: Double? = nil
    var intensity: String? = nil
    @Relationship var exercise: Exercise?
    
    var exerciseSetUUID: ExerciseSetUUID {
        .init(uuid)
    }
    
    enum CodingKeys: String, CodingKey {
        case weight, reps, restTime, intensity
    }
    
    convenience init(_ exerciseSet: ExerciseSet?) {
        if let exerciseSet {
            self.init(exerciseSet)
        } else {
            self.init()
        }
    }
    
    init(_ exerciseSet: ExerciseSet) {
        weight = exerciseSet.weight
        reps = exerciseSet.reps
        restTime = exerciseSet.restTime
        intensity = exerciseSet.intensity
    }
    
    init(weight: Double? = nil, reps: Double? = nil, restTime: Double? = nil, intensity: String? = nil) {
        self.weight = weight
        self.reps = reps
        self.restTime = restTime
        self.intensity = intensity
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        reps = try container.decodeIfPresent(Double.self, forKey: .reps)
        restTime = try container.decodeIfPresent(Double.self, forKey: .restTime)
        intensity = try container.decodeIfPresent(String.self, forKey: .intensity)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(reps, forKey: .reps)
        try container.encodeIfPresent(restTime, forKey: .restTime)
        try container.encodeIfPresent(intensity, forKey: .intensity)
    }
    
    var formattedWeight: String {
        weight?.formattedWithStepUnits(units: "kg") ?? "-"
    }
    
    var formattedReps: String {
        reps?.formattedWithStepUnits(step: 1.0, formatString: "%.0f", units: "reps") ?? "-"
    }
    
    var formattedRestTime: String {
        restTime?.formattedWithStepUnits(step: 0.5, formatString: "%.1f", units: "min") ?? "-"
    }
    
    static func getMock() -> ExerciseSet {
        .init(weight: Double(Int.random(in: 0...500))/4, reps: Double(Int.random(in: 6...15)), restTime: Double(Int.random(in: 1...8))/2, intensity: ["High", "Medium", "Low"].randomElement())
    }
}

extension Double {
    func formattedWithStepUnits(step: Double=0.25, formatString: String="%.2f", units: String? = nil) -> String {
        var unitsString = ""
        if let units {
            unitsString = " \(units)"
        }
        return String(format: formatString, (self / step).rounded() * step) + unitsString
    }
}
