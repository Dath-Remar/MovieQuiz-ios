import UIKit

final class MovieQuizPresenter {
    
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    var viewController: MovieQuizViewController? {
        didSet {
            // Теперь доступ к элементам ViewController возможен и они могут использоваться для логики ответов
        }
    }
    
    // MARK: - Display Logic
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func handleYesButtonClicked() {
        processAnswer(true)
    }

    func handleNoButtonClicked() {
        processAnswer(false)
    }
    
    func processAnswer(_ answer: Bool) {
        guard viewController?.yesButton.isEnabled ?? false, viewController?.noButton.isEnabled ?? false else { return }
        guard let currentQuestion = viewController?.currentQuestion else {
            return
        }
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            viewController?.correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
}
