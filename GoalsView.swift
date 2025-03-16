import SwiftUI

struct GoalsView: View {
    @State private var goals = Constants.defaultGoals
    @State private var showingAddGoal = false
    @State private var editingGoal: Goal?
    @State private var selectedGoal: Goal?
    @State private var showingCustomization = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(goals) { goal in
                        GoalCard(
                            goal: goal,
                            onEdit: { editingGoal = goal },
                            onDelete: { deleteGoal(goal) }
                        )
                        .transition(.scale.combined(with: .opacity))
                        .contextMenu {
                            Button {
                                withAnimation {
                                    deleteGoal(goal)
                                }
                            } label: {
                                HStack {
                                    Text("Удалить")
                                    Image(systemName: "trash")
                                }
                            }
                            
                            Button {
                                editingGoal = goal
                            } label: {
                                HStack {
                                    Text("Редактировать")
                                    Image(systemName: "pencil")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Цели")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddGoal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goals: $goals)
            }
            .sheet(item: $editingGoal) { goal in
                EditGoalView(goals: $goals, goal: goal)
            }
            .sheet(isPresented: $showingCustomization) {
                if let goal = selectedGoal {
                    CustomizeGoalView(goal: goal, goals: $goals)
                }
            }
        }
    }
    
    private func deleteGoal(_ goal: Goal) {
        withAnimation(.spring()) {
            goals.removeAll { $0.id == goal.id }
        }
    }
}

struct GoalCard: View {
    let goal: Goal
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text(formatDate(goal.deadline))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Progress section
            VStack(spacing: 6) {
                HStack {
                    Text("\(goal.currentValue)")
                        .font(.system(.subheadline, design: .rounded))
                    
                    Spacer()
                    
                    Text("\(Int(goal.progress * 100))%")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(goal.progress), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct EditGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var goals: [Goal]
    let goal: Goal
    
    @State private var name: String
    @State private var targetValue: String
    @State private var currentValue: String
    @State private var deadline: Date
    
    init(goals: Binding<[Goal]>, goal: Goal) {
        self._goals = goals
        self.goal = goal
        self._name = State(initialValue: goal.name)
        self._targetValue = State(initialValue: String(goal.targetValue))
        self._currentValue = State(initialValue: String(goal.currentValue))
        self._deadline = State(initialValue: goal.deadline)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название", text: $name)
                    TextField("Целевое значение", text: $targetValue)
                        .keyboardType(.numberPad)
                    TextField("Текущее значение", text: $currentValue)
                        .keyboardType(.numberPad)
                    DatePicker("Дедлайн", selection: $deadline, displayedComponents: [.date])
                }
            }
            .navigationTitle("Редактировать цель")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Отмена")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        updateGoal()
                    } label: {
                        Text("Сохранить")
                    }
                }
            }
        }
    }
    
    private func updateGoal() {
        guard let targetInt = Int(targetValue),
              let currentInt = Int(currentValue) else { return }
        
        let updatedGoal = Goal(
            name: name,
            targetValue: targetInt,
            currentValue: currentInt,
            deadline: deadline
        )
        
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            withAnimation {
                goals[index] = updatedGoal
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var goals: [Goal]
    
    @State private var name = ""
    @State private var currentValue = ""
    @State private var targetValue = ""
    @State private var deadline = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация")) {
                    TextField("Название цели", text: $name)
                    TextField("Текущее значение", text: $currentValue)
                        .keyboardType(.numberPad)
                    TextField("Целевое значение", text: $targetValue)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Срок")) {
                    DatePicker("Дедлайн", selection: $deadline, displayedComponents: [.date])
                }
            }
            .navigationTitle("Новая цель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Отмена")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        addGoal()
                    } label: {
                        Text("Добавить")
                    }
                    .disabled(name.isEmpty || currentValue.isEmpty || targetValue.isEmpty)
                }
            }
        }
    }
    
    private func addGoal() {
        guard let current = Double(currentValue),
              let target = Double(targetValue) else {
            return
        }
        
        let goal = Goal(name: name,
                       targetValue: Int(target),
                       currentValue: Int(current),
                       deadline: deadline)
        
        goals.append(goal)
        presentationMode.wrappedValue.dismiss()
    }
}

struct CustomizeGoalView: View {
    let goal: Goal
    @Binding var goals: [Goal]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedType: GoalType = .calories
    @State private var selectedFrequency: GoalFrequency = .daily
    @State private var customColor: Color = .blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тип цели")) {
                    Picker("Тип", selection: $selectedType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Частота")) {
                    Picker("Частота", selection: $selectedFrequency) {
                        ForEach(GoalFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                }
                
                Section(header: Text("Цвет")) {
                    ColorPicker("Выберите цвет", selection: $customColor)
                }
            }
            .navigationTitle("Настройка цели")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        // Здесь будет сохранение настроек
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 