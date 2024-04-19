import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate  {
    
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    
    weak var viewController: MovieQuizViewController?
    
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
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: isCorrect)
    }
    
    func didReceiveQuestion(question: QuizQuestion?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.hideLoadingIndicator()
            guard let question = question else {
                return
            }
            self.currentQuestion = question
            let viewModel = self.convert(model: question)
            UIView.transition(with: self.viewController?.view ?? UIView(), duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.viewController?.show(quiz: viewModel)
            })
        }
    }
    
    // Newly added methods to conform to the protocol
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.handleDataLoadingError(with: error)
    }

    func didReceiveError(error: Error) {
        viewController?.handleDataLoadingError(with: error)
    }
    
    func showFinalResult() {
        guard let viewController = viewController else { return }
        
        viewController.statisticService?.store(correct: correctAnswers, total: questionsAmount)
        let statisticsText = viewController.getStatisticsText()
        
        let messagePrefix = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Ваш результат: \(correctAnswers)/10"
        
        let finalMessage = "\(messagePrefix)\n\(statisticsText)"
        
        let model = AlertModel(title: "Этот раунд окончен!", message: finalMessage, buttonText: "Сыграть ещё раз") {
            viewController.resetQuiz()
        }
        
        viewController.alertPresenter.showAlert(model: model)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        viewController?.updateUIForAnswer(isCorrect: isCorrect)  // Обновляем UI в зависимости от ответа
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.viewController?.changeStateButtons(isEnabled: true) // Включаем кнопки после задержки
            if self.isLastQuestion() {
                self.showFinalResult()  // Показываем финальный результат, если это последний вопрос
            } else {
                self.switchToNextQuestion()  // Переключаем на следующий вопрос
                self.viewController?.showCurrentQuestion()  // Показываем текущий вопрос
            }
        }
    }
    
}
