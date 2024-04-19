import Foundation

// MARK: - QuestionFactoryProtocol

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData(completion: @escaping () -> Void)
}

