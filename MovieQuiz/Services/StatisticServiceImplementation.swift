import Foundation

// MARK: - StatisticServiceImplementation

class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGamesCount = gamesCount + 1
        let newCorrect = self.correct + count
        let newTotal = self.total + amount
        userDefaults.set(newCorrect, forKey: Keys.correct.rawValue)
        userDefaults.set(newTotal, forKey: Keys.total.rawValue)
        userDefaults.set(newGamesCount, forKey: Keys.gamesCount.rawValue)
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
        if newGameRecord.isBetterThan(bestGame) {
            bestGame = newGameRecord
        }
    }
    
    private var correct: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }

    private var total: Int {
        get {
            return userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }

    var totalAccuracy: Double {
        get {
            return Double(correct) / Double(total)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func updateGameStats(isCorrect: Bool) {
        if isCorrect {
            self.correct += 1
        }
        self.total += 1
    }
    
    func resetGameStats() {
        totalAccuracy = 0
        gamesCount = 0
        userDefaults.set(0, forKey: Keys.correct.rawValue)
        userDefaults.set(0, forKey: Keys.total.rawValue)
    }
}
