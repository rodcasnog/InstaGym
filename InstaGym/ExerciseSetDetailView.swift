//
//  ExerciseSetDetailView.swift
//  InstaGym
//
//  Copyright © 2025 Rodrigo Casado. All rights reserved.
//  Licensed under the MIT License. See LICENSE for details.
//
import SwiftUI
import Foundation

struct ExerciseSetDetailView: View {
    let exerciseSet: ExerciseSet
    @Binding var exerciseSets: [ExerciseSet]
    @State var internalExerciseSet: ExerciseSet
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    init(exerciseSet: ExerciseSet, exerciseSets: Binding<[ExerciseSet]>) {
        self.exerciseSet = exerciseSet
        self._exerciseSets = exerciseSets
        self.internalExerciseSet = ExerciseSet(exerciseSet)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Weight")) {
                EditNumericRowView(for: $internalExerciseSet.weight, step: 0.25, endValue: 450, numDigits: 2)
            }
            Section(header: Text("Reps")) {
                EditNumericRowView(for: $internalExerciseSet.reps, step: 1, endValue: 50, numDigits: 0)
            }
            Section(header: Text("Rest Time")) {
                EditNumericRowView(for: $internalExerciseSet.restTime, step: 0.5, endValue: 30, numDigits: 1)
            }
            Section(header: Text("Intensity")) {
                EditTextRowView(for: $internalExerciseSet.intensity)
            }
        }
        .navigationTitle("Edit set")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    let isNew = !exerciseSets.map(\ExerciseSet.uuid).contains(exerciseSet.uuid)
                    if isNew {
                        modelContext.insert(internalExerciseSet)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Failed to save context: \(error)")
                        }
                        exerciseSets.append(internalExerciseSet)
                    } else {
                        exerciseSet.weight = internalExerciseSet.weight
                        exerciseSet.reps = internalExerciseSet.reps
                        exerciseSet.restTime = internalExerciseSet.restTime
                        exerciseSet.intensity = internalExerciseSet.intensity
                    }
                    dismiss()
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct EditNumericRowView: View {
    @Binding var valueOpt: Double?
    @State var value: Double
    var step: Double
    let startValue: Double
    let endValue: Double
    let numDigits: Int
    
    init(for newValueOpt: Binding<Double?>, step: Double=1, startValue: Double=0, endValue: Double, numDigits: Int) {
        _valueOpt = newValueOpt
        _value = .init(initialValue: newValueOpt.wrappedValue ?? 0)
        self.step = step
        self.startValue = startValue
        self.endValue = endValue
        self.numDigits = numDigits
    }
    
    private func applyRounding() {
        var roundedValueOpt: Double? = nil
        if let valueOpt {
            roundedValueOpt = round(valueOpt / step) * step
        }
        if roundedValueOpt != valueOpt {
            valueOpt = roundedValueOpt
            value = valueOpt ?? 0
        }
    }
    
    var body: some View {
        HStack {
            TextField("Enter value", value: $valueOpt, format: .number.precision(.fractionLength(numDigits)))
                .keyboardType(.decimalPad)
                .onSubmit { applyRounding() }
            Stepper(value: $value, in: startValue...endValue, step: step) {
                EmptyView()
            }
        }
        .onChange(of: valueOpt) { oldValueOpt, newValueOpt in
            value = valueOpt ?? 0
        }
        .onChange(of: value) { oldValue, newValue in
            if valueOpt != nil || value > 0 {
                self.valueOpt = value
            }
        }
    }
}


struct EditTextRowView: View {
    @Binding var valueOpt: String?
    @State var value: String
    
    init(for newValueOpt: Binding<String?>) {
        _valueOpt = newValueOpt
        _value = .init(initialValue: newValueOpt.wrappedValue ?? "")
    }
    
    var body: some View {
        HStack {
            TextField("Type value", text: $value)
        }
        .onChange(of: valueOpt) { oldValueOpt, newValueOpt in
            if let newValueOpt {
                valueOpt = newValueOpt
            }
            value = valueOpt ?? ""
        }
        .onChange(of: value) { oldValue, newValue in
            valueOpt = value
        }
    }
}


#Preview {
    PreviewControl.start().wrapNav(ExerciseSetDetailView(exerciseSet: ExerciseSet.getMock(), exerciseSets: .constant([ExerciseSet.getMock()])))
}
