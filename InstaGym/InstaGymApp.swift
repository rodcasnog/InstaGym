//
//  InstaGymApp.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 25.11.2024.
//

import SwiftData
import SwiftUI

@main
struct InstaGymApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(for: Workout.self)
        .modelContainer(CustomContainer.create())
    }
}
