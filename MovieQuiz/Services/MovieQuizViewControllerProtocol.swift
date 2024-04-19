import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func updateUIForAnswer(isCorrect: Bool)
    func changeStateButtons(isEnabled: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showCurrentQuestion()
    func resetQuiz()
    func handleDataLoadingError(with error: Error)
}
