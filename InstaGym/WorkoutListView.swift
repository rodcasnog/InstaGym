//
//  WorkoutListView.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftData
import SwiftUI

struct WorkoutListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Workout.date, order: .reverse) var workouts: [Workout]
    @Environment(PathStorage.self) var pathStorage: PathStorage

    var body: some View {
        List {
            ForEach(workouts, id: \.uuid) { workout in
                NavigationLink(value: WorkoutUUID(workout.uuid)) {
                    HStack {
                        Text("\(workout.formattedDate)")
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(workout.exerciseArray.count) exercises")
                            Text(workout.formattedBodyParts)
                                .font(.caption)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(workouts[index])
                    try? modelContext.save()
                }
            }
        }
        .navigationBarTitle("Workout List")
        .navigationDestination(for: WorkoutUUID.self, destination: { workoutUUID in
            let workout = workouts.first(where: {$0.uuid == workoutUUID.id}) ?? Workout()
            WorkoutDetailView(workout)
                .environment(pathStorage)
        })
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                    Text("\(workouts.count) workouts")
            }
            ToolbarItem(placement: .automatic) {
                Button("Add workout", systemImage: "plus") {
                    let newWorkout = Workout(date: Date.now)
                    modelContext.insert(newWorkout)
                    try? modelContext.save()
                    pathStorage.path.append(WorkoutUUID(newWorkout.uuid))
                }
            }
        }
    }
}

#Preview {
    PreviewControl.start().wrapNav(WorkoutListView())
}
