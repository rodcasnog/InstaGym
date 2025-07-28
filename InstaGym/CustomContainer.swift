//
//  CustomContainer.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import Foundation
import SwiftData


actor CustomContainer {
    @MainActor
    static func create() -> ModelContainer {
        let schema = Schema([Workout.self])
        let config = ModelConfiguration()
        let container = try! ModelContainer(for: schema, configurations: [config])
        ExerciseType.insertDefaultTypes(container.mainContext)
//        for _ in 0...19 {
//            Workout.insertMock(container.mainContext)
//        }
        return container
    }
}
