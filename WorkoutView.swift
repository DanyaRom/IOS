import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var selectedCategory: WorkoutCategory = .everything
    @State private var searchText = ""
    
    private let workouts = Constants.defaultWorkouts
    
    private var filteredWorkouts: [Workout] {
        let filtered = selectedCategory == .everything ? workouts : workouts.filter { $0.category == selectedCategory }
        if searchText.isEmpty {
            return filtered
        }
        return filtered.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(WorkoutCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Поиск тренировок", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    // Тренировки
                    LazyVStack(spacing: 16) {
                        ForEach(filteredWorkouts, id: \.id) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutCard(workout: workout)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Тренировки")
        }
    }
}

struct CategoryButton: View {
    let category: WorkoutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(isSelected ? .bold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок и сложность
            HStack {
                Text(workout.name)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(workout.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(difficultyColor(workout.difficulty))
                    )
            }
            
            Text(workout.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Информация о тренировке
            HStack(spacing: 16) {
                WorkoutInfoBadge(
                    icon: "clock",
                    value: "\(workout.duration) мин",
                    color: .blue
                )
                
                WorkoutInfoBadge(
                    icon: "flame",
                    value: "\(workout.caloriesBurn) ккал",
                    color: .orange
                )
                
                WorkoutInfoBadge(
                    icon: "dumbbell",
                    value: "\(workout.exercises.count) упр.",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func difficultyColor(_ difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
}

struct WorkoutInfoBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(value)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var isStarted = false
    @State private var remainingTime: Int
    @State private var timer: Timer?
    @State private var showingCompletionAlert = false
    
    init(workout: Workout) {
        self.workout = workout
        _remainingTime = State(initialValue: workout.duration * 60)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timer section
                VStack {
                    Text(timeString(from: remainingTime))
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(isStarted ? .blue : .primary)
                    
                    Button(action: toggleTimer) {
                        Text(isStarted ? "Пауза" : "Старт")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 44)
                            .background(isStarted ? Color.red : Color.blue)
                            .cornerRadius(22)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                
                // Workout info
                VStack(alignment: .leading, spacing: 16) {
                    Text("Информация")
                        .font(.title2)
                        .bold()
                    
                    HStack {
                        InfoCard(icon: "clock", title: "Длительность", value: "\(workout.duration) мин")
                        InfoCard(icon: "flame", title: "Калории", value: "\(workout.caloriesBurn) ккал")
                    }
                    
                    Text(workout.description)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                
                // Exercises
                VStack(alignment: .leading, spacing: 16) {
                    Text("Упражнения")
                        .font(.title2)
                        .bold()
                    
                    ForEach(workout.exercises, id: \.id) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
            }
            .padding()
        }
        .navigationTitle(workout.name)
        .background(Color(.systemGroupedBackground))
        .onDisappear {
            timer?.invalidate()
        }
        .alert(isPresented: $showingCompletionAlert) {
            Alert(
                title: Text("Тренировка завершена!"),
                message: Text("Вы сожгли примерно \(workout.caloriesBurn) калорий"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func toggleTimer() {
        if isStarted {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isStarted = false
                    showingCompletionAlert = true
                }
            }
        }
        isStarted.toggle()
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    private func setsString(_ sets: Int) -> String {
        switch sets {
        case 1: return "подход"
        case 2...4: return "подхода"
        default: return "подходов"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
            
            Text(exercise.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if exercise.reps > 0 {
                Text("\(exercise.sets) \(setsString(exercise.sets)) × \(exercise.reps) повторений")
                    .font(.caption)
                    .foregroundColor(.blue)
            } else if exercise.duration > 0 {
                Text("\(exercise.sets) \(setsString(exercise.sets)) × \(exercise.duration) сек")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 