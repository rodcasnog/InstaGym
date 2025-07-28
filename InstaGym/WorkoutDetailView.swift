//
//  WorkoutDetailView.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 26.11.2024.
//

import SwiftData
import SwiftUI

struct WorkoutDetailView: View {
    @State var workout: Workout
    
    @Environment(\.modelContext) var modelContext
    @Environment(PathStorage.self) var pathStorage: PathStorage

    init(_ workout: Workout) {
        self.workout = workout
    }
    
    var body: some View {
        Text(workout.formattedBodyParts)
            .font(.caption)
        List {
            ForEach(workout.exerciseArray, id: \.uuid) { exercise in
                NavigationLink(value: ExerciseUUID(exercise.uuid)) {
                    VStack {
                        HStack {
                            Text(exercise.formattedExerciseTypeName)
                                .font(.subheadline)
                            Spacer()
                            Text("\(exercise.setArray.count) sets")
                                .font(.subheadline)
                        }
                        .padding([.bottom], 5)
                        VStack() {
                            ForEach(exercise.setArray, id: \.uuid) { set in
                                HStack {
                                    Text(set.formattedReps)
                                    Spacer()
                                    Text(set.formattedWeight)
                                }
                            }
                        }
                        .padding([.trailing, .leading], 10)
                        .font(.caption)
                    }
                }
            }
            .onDelete { indexSet in
                var exercisesToRemove = [Exercise]()
                indexSet.forEach { exercisesToRemove.append(workout.exerciseArray[$0]) }
                workout.removeExercise(exercisesToRemove)
                exercisesToRemove.forEach { modelContext.delete($0) }
                try? modelContext.save()
            }
            .onMove { source, destination in
                var exercisesToMove = [Exercise]()
                source.forEach { exercisesToMove.append(workout.exerciseArray[$0]) }
                workout.moveExercise(exercisesToMove, to: destination)
                try? modelContext.save()
                
            }
        }
        .navigationTitle(Text("Workout - \(workout.formattedDate)"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(workout.exerciseArray.count) exercises")
                    .font(.caption)
            }
            ToolbarItem(placement: .automatic) {
                NavigationLink {
                    let newExercise = Exercise()
                    ExerciseTypeSelectionView() { exerciseType in
                        newExercise.exerciseType = exerciseType
                        modelContext.insert(newExercise)
                        try? modelContext.save()
                        workout.exercises.append(newExercise)
                        try? modelContext.save()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: ExerciseUUID.self, destination: { exerciseUUID in
            let exercise = workout.exerciseArray.first(where: {$0.uuid == exerciseUUID.id}) ?? Exercise()
            ExerciseDetailView(exercise)
                .environment(pathStorage)
        })
    }
}

#Preview {
    {
        let previewControl = PreviewControl.start()
        let workout = previewControl.workouts.first!
        return previewControl.wrapNav(WorkoutDetailView(workout))
    }()
}
