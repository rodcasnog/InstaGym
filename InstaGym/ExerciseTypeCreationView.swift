//
//  ExerciseTypeCreationView.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftData
import SwiftUI

struct ExerciseTypeCreationView: View {
    @Binding var preselectedExerciseType: ExerciseType?
    @Binding var preselectedBodyPart: BodyPart
    
    @State var exerciseTypeName = ""
    @State var exerciseTypeBodyPart: BodyPart
    @State var exerciseAlreadyExists: Bool = false
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    init(preselectedExerciseType: Binding<ExerciseType?>, preselectedBodyPart: Binding<BodyPart>) {
        _preselectedExerciseType = preselectedExerciseType
        _preselectedBodyPart = preselectedBodyPart
        exerciseTypeBodyPart = preselectedBodyPart.wrappedValue
    }
    
    var body: some View {
        List {
            Section {
                TextField("Type new exercise name", text: $exerciseTypeName)
            } header: {
                Text("New exercise name")
            } footer: {
                VStack {
                    if exerciseAlreadyExists {
                        Text("Exercise already exists")
                    }
                }
                .frame(minHeight: 20)
            }
            Section {
                ForEach(BodyPart.allValidCases, id: \.self) { bodyPart in
                    Button(bodyPart.rawValue) {
                        exerciseTypeBodyPart = bodyPart
                    }
                    .foregroundStyle(exerciseTypeBodyPart == bodyPart ? .primary : .secondary)
                }
            } header: {
                Text("New exercise body part")
            }
        }
        .navigationBarTitle("Create new exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dismiss", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    let newExerciseType = try! ExerciseType.fetchOrCreate(withName: exerciseTypeName, withBodyPart: exerciseTypeBodyPart, using: modelContext)
                    try? modelContext.save()
                    preselectedExerciseType = newExerciseType
                    preselectedBodyPart = newExerciseType.bodyPart
                    dismiss()
                }
                .disabled(exerciseTypeName.isEmpty || exerciseTypeBodyPart == .unknown || exerciseAlreadyExists)
            }
        }
        .onChange(of: exerciseTypeName) { oldExerciseTypeName, newExerciseTypeName in
            if ExerciseType.fetch(withName: newExerciseTypeName, using: modelContext) != nil {
                exerciseAlreadyExists = true
            } else {
                exerciseAlreadyExists = false
            }
        }
    }
}

#Preview {
    {
        let previewControl = PreviewControl.start()
        let exercise = previewControl.workouts.first!.exercises.first!
        return previewControl.wrapNav(ExerciseTypeCreationView(preselectedExerciseType: .constant(exercise.exerciseType), preselectedBodyPart: .constant(exercise.exerciseType?.bodyPart ?? .unknown)))
    }()
}
