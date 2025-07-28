//
//  InstaGymApp.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
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
