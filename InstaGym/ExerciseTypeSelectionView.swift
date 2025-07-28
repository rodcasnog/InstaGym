//
//  ExerciseTypeSelectionView.swift.swift
//  InstaGym
//
//  Created by Rodrigo Casado on 03.12.2024.
//

import SwiftData
import SwiftUI

struct ExerciseTypeSelectionView: View {
    @State var selectedExerciseType: ExerciseType?
    @State var selectedBodyPart: BodyPart
    var onSave: ((ExerciseType) -> Void)?
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: [
        SortDescriptor(\ExerciseType.rawBodyPart),
        SortDescriptor(\ExerciseType.name)
    ]) var allExerciseTypes: [ExerciseType]
    
    init(_ selectedExerciseType: ExerciseType? = nil, onSave: ((ExerciseType) -> Void)?=nil) {
        self.selectedExerciseType = selectedExerciseType
        self.selectedBodyPart = selectedExerciseType?.bodyPart ?? .unknown
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    if let selectedExerciseType {
                        Text(selectedExerciseType.name)
                    } else {
                        Text("Select an exercise")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Current exercise")
                        .foregroundStyle(.blue)
                }
                
                switch selectedBodyPart {
                    
                case .unknown:
                    Section {
                        ForEach(BodyPart.allValidCases, id: \.self) { bodyPart in
                            Button(bodyPart.rawValue) {
                                selectedBodyPart = bodyPart
                            }
                            .foregroundStyle(selectedExerciseType?.bodyPart == bodyPart ? .primary : .secondary)
                        }
                    } header: {
                        Text("Choose a body part")
                            .foregroundStyle(.blue)
                    }
                    
                default:
                    Section {
                        HStack {
                            Text("\(selectedBodyPart.rawValue)")
                            Spacer()
                            Button("Unselect", role: .cancel) {
                                selectedBodyPart = .unknown
                            }
                            .buttonStyle(PlainButtonStyle())
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    } header: {
                        Text("Selected body part")
                            .foregroundStyle(.blue)
                    }
                    
                    Section {
                        ForEach(allExerciseTypes.filter {$0.bodyPart == selectedBodyPart}, id: \.uuid) { exerciseType in
                            Button(exerciseType.name) {
                                selectedExerciseType = exerciseType
                            }
                            .foregroundStyle(selectedExerciseType == exerciseType ? .primary : .secondary)
                        }
                    } header: {
                        Text("Choose an exercise")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .navigationTitle("Select exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .bottomBar) {
                NavigationLink(destination: ExerciseTypeCreationView(preselectedExerciseType: $selectedExerciseType, preselectedBodyPart:  $selectedBodyPart)) {
                    Text("Add new exercise")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    if let selectedExerciseType {
                        if let onSave {
                            onSave(selectedExerciseType)
                        }
                    }
                    dismiss()
                }
                .disabled(selectedExerciseType?.bodyPart == nil)
            }
        }
    }
}

#Preview {
    {
        let previewControl = PreviewControl.start()
        let exercise = previewControl.workouts.first!.exercises.first!
        return previewControl.wrapNav(ExerciseTypeSelectionView())
    }()
}
