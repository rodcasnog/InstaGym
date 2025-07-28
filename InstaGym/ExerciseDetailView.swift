//
//  ExerciseDetailView.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 27.11.2024.
//

import SwiftData
import SwiftUI

struct ExerciseDetailView: View {
    @State var exercise: Exercise
    @Environment(\.modelContext) var modelContext
    @Environment(PathStorage.self) var pathStorage: PathStorage
    
    init(_ exercise: Exercise) {
        self.exercise = exercise
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Button("Add set", systemImage: "plus") {
                        let newExerciseSet = ExerciseSet(exercise.setArray.last)
                        modelContext.insert(newExerciseSet)
                        try? modelContext.save()
                        exercise.insertSet(newExerciseSet)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Repetitions")
                    Spacer()
                    Text("Weight")
                }
                .font(.headline)
                ForEach(exercise.setArray, id: \.uuid) { exerciseSet in
                    HStack {
                        Text(exerciseSet.formattedReps)
                        Spacer()
                        Text(exerciseSet.formattedWeight)
                    }
                }
                .onDelete { indexSet in
                    var setsToRemove = [ExerciseSet]()
                    indexSet.forEach { setsToRemove.append(exercise.setArray[$0]) }
                    exercise.removeSet(setsToRemove)
                    setsToRemove.forEach { modelContext.delete($0) }
                    try? modelContext.save()
                }
                .onMove { source, destination in
                    var setsToMove = [ExerciseSet]()
                    source.forEach { setsToMove.append(exercise.setArray[$0]) }
                    exercise.moveSet(setsToMove, to: destination)
                    try? modelContext.save()
                }
            }
        }
        .navigationTitle(exercise.formattedExerciseTypeName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: ExerciseTypeSelectionView(exercise.exerciseType) { exerciseType in
                    exercise.exerciseType = exerciseType
                    try? modelContext.save()
                }) {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Text("\(exercise.setArray.count) sets")
            }
        }
    }
}

#Preview {
    {
        let previewControl = PreviewControl.start()
        let exercise = previewControl.workouts.first!.exercises.first!
        return previewControl.wrapNav(ExerciseDetailView(exercise))
    }()
}
