import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings
    
    @State private var calorieGoal: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Цели")) {
                    HStack {
                        Text("Дневная норма калорий")
                        Spacer()
                        TextField("ккал", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        if let goal = Int(calorieGoal) {
                            settings.dailyCalorieGoal = goal
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                calorieGoal = "\(settings.dailyCalorieGoal)"
            }
        }
    }
} 