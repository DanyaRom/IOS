import SwiftUI

struct ContentView: View {
    @StateObject private var userSettings = UserSettings()
    
    var body: some View {
        TabView {
            CaloriesView()
                .tabItem {
                    Image(systemName: "flame")
                    Text("Калории")
                }
            
            WorkoutView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Тренировки")
                }
            
            GoalsView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Цели")
                }
        }
        .accentColor(Color(.systemBlue))
        .environmentObject(userSettings)
    }
}

struct CaloriesView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var meals: [Meal] = []
    @State private var showingAddFood = false
    @State private var showingSettings = false
    
    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Круговой прогресс
                    CalorieProgressView(
                        consumed: totalCalories,
                        goal: settings.dailyCalorieGoal
                    )
                    .frame(width: 250, height: 250)
                    .padding(.top)
                    .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Статистика
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Осталось",
                            value: "\(max(0, settings.dailyCalorieGoal - totalCalories))",
                            icon: "minus.circle.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Съедено",
                            value: "\(totalCalories)",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Приемы пищи
                    VStack(spacing: 15) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSection(
                                mealType: mealType,
                                meals: meals.filter { $0.mealType == mealType },
                                onDelete: { indexSet, meals in
                                    for index in indexSet {
                                        withAnimation(.spring()) {
                                            self.meals.removeAll { $0.id == meals[index].id }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            )
            .navigationTitle("Калории")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddFood = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(meals: $meals)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct MealSection: View {
    let mealType: MealType
    let meals: [Meal]
    let onDelete: (IndexSet, [Meal]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(mealType.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text("\(meals.reduce(0) { $0 + $1.calories }) ккал")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if meals.isEmpty {
                EmptyMealView()
            } else {
                ForEach(meals) { meal in
                    MealRow(meal: meal)
                }
                .onDelete { indexSet in
                    onDelete(indexSet, meals)
                }
            }
        }
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.system(.body, design: .rounded))
                
                HStack {
                    Text("\(meal.calories) ккал")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                    
                    Text(meal.timeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct EmptyMealView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                Text("Нет записей")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct CalorieProgressView: View {
    let consumed: Int
    let goal: Int
    
    private var progress: CGFloat {
        min(CGFloat(consumed) / CGFloat(goal), 1.0)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: 20
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .purple, .red]),
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(), value: progress)
            
            VStack(spacing: 4) {
                Text("\(consumed)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("из \(goal) ккал")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings())
    }
} 