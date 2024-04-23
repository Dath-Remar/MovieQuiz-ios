import UIKit
import Reachability

// MARK: - MovieQuizPresenter Declaration

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    weak var viewController: MovieQuizViewController?
    var statisticService: StatisticService?
    private let reachability = try! Reachability()
    
    // MARK: - Initializers
    
    init(statisticService: StatisticService?) {
        self.questionFactory = QuestionFactory(delegate: self)
        self.statisticService = statisticService
    }
    
    // MARK: - Reachability
    
    func isConnectedToNetwork() -> Bool {
        reachability.whenReachable = { _ in
            print("Сеть доступна")
        }
        reachability.whenUnreachable = { _ in
            print("Сеть недоступна")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Не удалось запустить уведомления")
        }
        
        return reachability.connection != .unavailable
    }
    
    // MARK: - QuestionFactoryDelegate Methods
    
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
    
    func didFailToLoadData(with error: Error) {
        viewController?.handleDataLoadingError(with: error)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
    }
    
    func didReceiveError(error: Error) {
        viewController?.handleDataLoadingError(with: error)
    }
    
    // MARK: - Error Handling Methods
    
    func handleDataLoadingError(with error: Error) {
        let alertModel = AlertModel(
            title: "Ошибка",
            message: error.localizedDescription,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            self.viewController?.hideLoadingIndicator()
            self.viewController?.resetQuiz()
            self.viewController?.showLoadingIndicator()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.attemptToReloadData()
            }
        }
        viewController?.alertPresenter.showAlert(model: alertModel)
    }
    
    private func attemptToReloadData() {
        if !isConnectedToNetwork() {
            handleNoInternetConnection()
            return
        }
        self.questionFactory?.loadData(completion: { [weak self] in
            self?.viewController?.showCurrentQuestion()
        })
    }
    
    private func handleNoInternetConnection() {
        let alertModel = AlertModel(
            title: "Нет соединения",
            message: "Подключение к Интернету отсутствует. Пожалуйста, проверьте ваше соединение и попробуйте снова.",
            buttonText: "OK",
            completion: {}
        )
        viewController?.alertPresenter.showAlert(model: alertModel)
    }
    
    // MARK: - Quiz Management Methods
    
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
    
    // MARK: - Response Handling Methods
    
    func handleYesButtonClicked() {
        processAnswer(true)
    }
    
    func handleNoButtonClicked() {
        processAnswer(false)
    }
    
    private func processAnswer(_ answer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.changeStateButtons(isEnabled: false)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.updateUIForAnswer(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.isLastQuestion() {
                self.showFinalResult()
            } else {
                self.switchToNextQuestion()
                self.viewController?.showCurrentQuestion()
            }
            self.viewController?.changeStateButtons(isEnabled: true)
        }
    }
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // MARK: - Final Results Presentation
    
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
    
    // MARK: - Statistical Methods
    
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
        Количество сыгранных викторин: \(gamesPlayed)
        Рекорд: \(bestGameScore) (\(bestGameDate))
        Средняя точность: \(overallAccuracy)
        """
    }
}
