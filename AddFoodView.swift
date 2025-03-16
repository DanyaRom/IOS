import SwiftUI

struct AddFoodView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var meals: [Meal]
    @State private var foodName = ""
    @State private var calories = ""
    @State private var selectedMealType = MealType.breakfast
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Название", text: $foodName)
                    TextField("Калории", text: $calories)
                        .keyboardType(.numberPad)
                    Picker("Тип приема пищи", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Добавить еду")
            .navigationBarItems(
                leading: Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Сохранить") {
                    addFood()
                }
            )
        }
    }
    
    private func addFood() {
        if let caloriesInt = Int(calories), !foodName.isEmpty {
            let meal = Meal(
                name: foodName,
                calories: caloriesInt,
                mealType: selectedMealType,
                date: Date()
            )
            meals.append(meal)
            presentationMode.wrappedValue.dismiss()
        }
    }
} 