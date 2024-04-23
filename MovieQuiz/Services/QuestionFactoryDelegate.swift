import Foundation

// MARK: - QuestionFactoryDelegateProtocol

protocol QuestionFactoryDelegate: AnyObject {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didReceiveError(error: Error)
    func didReceiveQuestion(question: QuizQuestion?)
}

