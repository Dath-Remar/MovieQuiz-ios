import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticService?
    
    // MARK: - Initializers
    init(statisticService: StatisticService?) {
        self.questionFactory = QuestionFactory(delegate: self)
        self.statisticService = statisticService
    }
    
    // MARK: - Public Methods
    
    func getStatisticsText() -> String {
        guard let statisticsService = statisticService else {
            return "Статистика недоступна"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let gamesPlayed = statisticsService.gamesCount
        let bestGameScore = "\(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total)"
        let bestGameDate = dateFormatter.string(from: statisticsService.bestGame.date)
        let overallAccuracy = String(format: "%.2f%%", statisticsService.totalAccuracy * 100)
        return """
        Количество сыгранных квизов: \(gamesPlayed)
        Рекорд: \(bestGameScore) (\(bestGameDate))
        Средняя точность: \(overallAccuracy)
        """
    }
    
    func startQuiz() {
        questionFactory?.loadData(completion: {
            self.viewController?.showCurrentQuestion()
        })
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    func handleYesButtonClicked() {
        processAnswer(true)
    }
    
    func handleNoButtonClicked() {
        processAnswer(false)
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
        let statisticsText = getStatisticsText()
        
        let messagePrefix = correctAnswers == questionsAmount ?
        "Поздравляем, вы ответили на 10 из 10!" :
        "Ваш результат: \(correctAnswers)/10"
        
        let finalMessage = "\(messagePrefix)\n\(statisticsText)"
        
        let model = AlertModel(title: "Этот раунд окончен!", message: finalMessage, buttonText: "Сыграть ещё раз") {
            viewController.resetQuiz()
        }
        
        viewController.alertPresenter.showAlert(model: model)
    }
    
    // MARK: - Private Methods
    
    private func processAnswer(_ answer: Bool) {
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
    
    private func showAnswerResult(isCorrect: Bool) {
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
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
