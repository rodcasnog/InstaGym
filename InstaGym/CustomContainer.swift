//
//  CustomContainer.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 15.12.2024.
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
