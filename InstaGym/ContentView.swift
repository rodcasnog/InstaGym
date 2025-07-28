//
//  ContentView.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftData
import SwiftUI

struct ContentView: View {
    @State var pathStorage = PathStorage()
    var body: some View {
        NavigationStack(path: $pathStorage.path) {
            WorkoutListView()
                .environment(pathStorage)
        }
    }
}

#Preview {
    PreviewControl.start().wrap(ContentView())
}

@MainActor
class PreviewControl {
    static var workouts = [Workout]()
    static var container: ModelContainer? = nil
    
    static func start() -> PreviewControl.Type {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: Workout.self, configurations: config)
        ExerciseType.insertDefaultTypes(container!.mainContext)
        for _ in 0...9 {
            workouts.append(Workout.insertMock(container!.mainContext))
        }
        return PreviewControl.self
    }
    
    static func wrap(_ view: some View) -> some View {
        return view.modelContainer(container!)
    }
    
    @State static var pathStorage = PathStorage()
    
    static func wrapNav(_ view: some View) -> some View {
//        pathStorage.clean()
        return NavigationStack(path: $pathStorage.path) {
            view.modelContainer(container!).environment(pathStorage)
        }
    }
}
