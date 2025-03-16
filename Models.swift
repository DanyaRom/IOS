import SwiftUI
import Foundation

// MARK: - Activity Level
enum ActivityLevel: String, Codable, CaseIterable {
    case low = "Низкая"
    case moderate = "Умеренная"
    case high = "Высокая"
    case veryHigh = "Очень высокая"
    
    var description: String {
        switch self {
        case .low: return "Низкая"
        case .moderate: return "Умеренная"
        case .high: return "Высокая"
        case .veryHigh: return "Очень высокая"
        }
    }
}

// MARK: - Meal Types
enum MealType: String, Codable, CaseIterable {
    case breakfast = "Завтрак"
    case lunch = "Обед"
    case dinner = "Ужин"
    case snack = "Перекус"
}

// MARK: - Meal Model
struct Meal: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let mealType: MealType
    let date: Date
    
    init(id: UUID = UUID(), name: String, calories: Int, mealType: MealType, date: Date) {
        self.id = id
        self.name = name
        self.calories = calories
        self.mealType = mealType
        self.date = date
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Goal Models
struct Goal: Identifiable, Codable {
    let id: UUID
    let name: String
    let targetValue: Int
    var currentValue: Int
    let deadline: Date
    
    init(id: UUID = UUID(), name: String, targetValue: Int, currentValue: Int, deadline: Date) {
        self.id = id
        self.name = name
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.deadline = deadline
    }
    
    var progress: Double {
        Double(currentValue) / Double(targetValue)
    }
}

enum GoalFrequency: String, Codable, CaseIterable {
    case daily = "Ежедневная"
    case weekly = "Еженедельная"
    case monthly = "Ежемесячная"
    case custom = "Своя"
}

enum GoalType: String, Codable, CaseIterable {
    case calories = "Калории"
    case weight = "Вес"
    case water = "Вода"
    case steps = "Шаги"
    case workout = "Тренировки"
    case protein = "Протеин"
    case meditation = "Медитация"
    case sleep = "Сон"
}

// MARK: - Achievement System
struct Achievement: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var type: AchievementType
    var isUnlocked: Bool
    var progress: Double
    var icon: String // SF Symbol name
    
    init(id: UUID = UUID(), name: String, description: String, type: AchievementType, isUnlocked: Bool, progress: Double, icon: String) {
        self.id = id
        self.name = name
        self.description = description
        self.type = type
        self.isUnlocked = isUnlocked
        self.progress = progress
        self.icon = icon
    }
}

enum AchievementType: String, Codable {
    case workoutStreak = "Серия тренировок"
    case calorieGoal = "Цель по калориям"
    case stepMaster = "Мастер шагов"
    case waterBalance = "Водный баланс"
    case weightGoal = "Цель по весу"
}

// MARK: - Workout Models
enum WorkoutCategory: String, Codable, CaseIterable {
    case everything = "Все"
    case cardio = "Кардио"
    case strength = "Силовая"
    case flexibility = "Гибкость"
    case hiit = "HIIT"
    case yoga = "Йога"
    case pilates = "Пилатес"
}

struct Workout: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: Int // в минутах
    let caloriesBurn: Int
    let exercises: [Exercise]
    let category: WorkoutCategory
    let difficulty: WorkoutDifficulty
    
    init(id: UUID = UUID(), name: String, description: String, duration: Int, caloriesBurn: Int, exercises: [Exercise], category: WorkoutCategory, difficulty: WorkoutDifficulty) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.caloriesBurn = caloriesBurn
        self.exercises = exercises
        self.category = category
        self.difficulty = difficulty
    }
}

enum WorkoutDifficulty: String, Codable, CaseIterable {
    case beginner = "Начинающий"
    case intermediate = "Средний"
    case advanced = "Продвинутый"
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let sets: Int
    let reps: Int
    let duration: Int // в секундах
    
    init(id: UUID = UUID(), name: String, description: String, sets: Int = 1, reps: Int = 0, duration: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.sets = sets
        self.reps = reps
        self.duration = duration
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Грудь"
    case back = "Спина"
    case legs = "Ноги"
    case shoulders = "Плечи"
    case arms = "Руки"
    case core = "Пресс"
    case fullBody = "Все тело"
}

// MARK: - Constants
struct Constants {
    static let defaultCalorieGoal = 2000
    static let cornerRadius: CGFloat = 15
    static let shadowRadius: CGFloat = 5
    
    static let defaultGoals: [Goal] = [
        Goal(name: "Дневная норма калорий", targetValue: 2000, currentValue: 0, deadline: Date().addingTimeInterval(86400)),
        Goal(name: "Вода", targetValue: 2000, currentValue: 500, deadline: Date().addingTimeInterval(86400)),
        Goal(name: "Шаги", targetValue: 10000, currentValue: 2500, deadline: Date().addingTimeInterval(86400))
    ]
    
    static let defaultWorkouts: [Workout] = [
        // КАРДИО
        Workout(
            name: "Интервальный бег",
            description: "Чередование быстрого и медленного бега для максимального сжигания калорий",
            duration: 30,
            caloriesBurn: 300,
            exercises: [
                Exercise(name: "Разминка", description: "Легкий бег", duration: 300),
                Exercise(name: "Спринт", description: "Максимальная скорость", sets: 8, reps: 0, duration: 30),
                Exercise(name: "Медленный бег", description: "Восстановление", sets: 8, reps: 0, duration: 60),
                Exercise(name: "Заминка", description: "Легкий бег", duration: 300)
            ],
            category: .cardio,
            difficulty: .intermediate
        ),
        
        // СИЛОВАЯ
        Workout(
            name: "Тренировка верха тела",
            description: "Комплексная тренировка для развития силы верхней части тела",
            duration: 45,
            caloriesBurn: 250,
            exercises: [
                Exercise(name: "Отжимания", description: "Классические отжимания", sets: 4, reps: 12),
                Exercise(name: "Подтягивания", description: "Подтягивания широким хватом", sets: 4, reps: 8),
                Exercise(name: "Брусья", description: "Отжимания на брусьях", sets: 3, reps: 10)
            ],
            category: .strength,
            difficulty: .advanced
        ),
        
        // ЙОГА
        Workout(
            name: "Утренняя йога",
            description: "Мягкий комплекс для энергичного начала дня",
            duration: 20,
            caloriesBurn: 120,
            exercises: [
                Exercise(name: "Поза собаки", description: "Поза собаки мордой вниз", duration: 60),
                Exercise(name: "Поза воина", description: "Поза воина 1", sets: 2, reps: 0, duration: 45),
                Exercise(name: "Поза кошки", description: "Растяжка спины", duration: 60)
            ],
            category: .yoga,
            difficulty: .beginner
        ),
        
        // HIIT
        Workout(
            name: "Взрывной HIIT",
            description: "Интенсивная интервальная тренировка для быстрого результата",
            duration: 25,
            caloriesBurn: 400,
            exercises: [
                Exercise(name: "Берпи", description: "Максимальная интенсивность", sets: 5, reps: 10),
                Exercise(name: "Прыжки", description: "Прыжки с разведением ног", sets: 5, reps: 20),
                Exercise(name: "Планка", description: "С касанием плеч", sets: 5, reps: 15)
            ],
            category: .hiit,
            difficulty: .advanced
        ),
        
        // ГИБКОСТЬ
        Workout(
            name: "Растяжка всего тела",
            description: "Комплексная растяжка для улучшения гибкости",
            duration: 35,
            caloriesBurn: 150,
            exercises: [
                Exercise(name: "Наклоны", description: "Наклоны к прямым ногам", sets: 3, reps: 0, duration: 45),
                Exercise(name: "Бабочка", description: "Растяжка внутренней части бедра", duration: 60),
                Exercise(name: "Мостик", description: "Прогиб спины", sets: 3, reps: 0, duration: 30)
            ],
            category: .flexibility,
            difficulty: .beginner
        ),
        
        // ПИЛАТЕС
        Workout(
            name: "Пилатес для пресса",
            description: "Укрепление кора и улучшение осанки",
            duration: 40,
            caloriesBurn: 200,
            exercises: [
                Exercise(name: "Сотня", description: "Классическое упражнение", duration: 120),
                Exercise(name: "Скручивания", description: "Подъемы корпуса", sets: 3, reps: 15),
                Exercise(name: "Планка", description: "Удержание", sets: 3, reps: 0, duration: 60)
            ],
            category: .pilates,
            difficulty: .intermediate
        ),
        
        // ЕЩЕ КАРДИО
        Workout(
            name: "Кардио-микс",
            description: "Разнообразная кардио тренировка",
            duration: 35,
            caloriesBurn: 280,
            exercises: [
                Exercise(name: "Джампинг джек", description: "Прыжки с разведением рук и ног", sets: 4, reps: 25),
                Exercise(name: "Скакалка", description: "Прыжки на скакалке", duration: 180),
                Exercise(name: "Степ-ап", description: "Подъемы на платформу", sets: 3, reps: 20)
            ],
            category: .cardio,
            difficulty: .intermediate
        ),
        
        // ЕЩЕ СИЛОВАЯ
        Workout(
            name: "Тренировка ног",
            description: "Мощная тренировка нижней части тела",
            duration: 50,
            caloriesBurn: 350,
            exercises: [
                Exercise(name: "Приседания", description: "Классические приседания", sets: 4, reps: 15),
                Exercise(name: "Выпады", description: "Выпады вперед", sets: 3, reps: 12),
                Exercise(name: "Подъемы на носки", description: "Для икроножных мышц", sets: 4, reps: 20)
            ],
            category: .strength,
            difficulty: .intermediate
        ),
        
        // ЕЩЕ ЙОГА
        Workout(
            name: "Вечерняя йога",
            description: "Расслабляющий комплекс для завершения дня",
            duration: 25,
            caloriesBurn: 100,
            exercises: [
                Exercise(name: "Поза ребенка", description: "Расслабление спины", sets: 1, reps: 0, duration: 120),
                Exercise(name: "Скручивания лежа", description: "Для позвоночника", sets: 2, reps: 0, duration: 60),
                Exercise(name: "Шавасана", description: "Поза полного расслабления", sets: 1, reps: 0, duration: 300)
            ],
            category: .yoga,
            difficulty: .beginner
        ),
        
        // ЕЩЕ HIIT
        Workout(
            name: "Табата",
            description: "Классическая табата-тренировка",
            duration: 20,
            caloriesBurn: 250,
            exercises: [
                Exercise(name: "Приседания с прыжком", description: "20 сек работы, 10 сек отдыха", sets: 8, reps: 8),
                Exercise(name: "Горизонтальный бег", description: "20 сек работы, 10 сек отдыха", sets: 8, reps: 8),
                Exercise(name: "Отжимания", description: "20 сек работы, 10 сек отдыха", sets: 8, reps: 8)
            ],
            category: .hiit,
            difficulty: .advanced
        )
    ]
    
    static let defaultAchievements: [Achievement] = [
        Achievement(
            name: "Первые шаги",
            description: "Выполните первую тренировку",
            type: .workoutStreak,
            isUnlocked: false,
            progress: 0,
            icon: "figure.walk"
        ),
        Achievement(
            name: "Водный баланс",
            description: "Достигните цели по воде 7 дней подряд",
            type: .waterBalance,
            isUnlocked: false,
            progress: 0,
            icon: "drop.fill"
        ),
        Achievement(
            name: "Марафонец",
            description: "Пройдите 100000 шагов за неделю",
            type: .stepMaster,
            isUnlocked: false,
            progress: 0,
            icon: "figure.walk.motion"
        )
    ]
}

// MARK: - User Settings
class UserSettings: ObservableObject, Codable {
    enum CodingKeys: String, CodingKey {
        case dailyCalorieGoal
    }
    
    @Published var dailyCalorieGoal: Int {
        didSet {
            UserDefaults.standard.set(dailyCalorieGoal, forKey: "dailyCalorieGoal")
        }
    }
    
    init() {
        self.dailyCalorieGoal = UserDefaults.standard.integer(forKey: "dailyCalorieGoal")
        if self.dailyCalorieGoal == 0 {
            self.dailyCalorieGoal = 2000 // Значение по умолчанию
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dailyCalorieGoal = try container.decode(Int.self, forKey: .dailyCalorieGoal)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dailyCalorieGoal, forKey: .dailyCalorieGoal)
    }
} 
