import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        processAnswer(false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        processAnswer(true)
    }
    // MARK: - IBOutlet
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var question: UILabel!
    
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private var statisticService: StatisticService?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuiz()
    }
    
    // MARK: - Setup
    private func setupQuiz() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        overrideUserInterfaceStyle = .dark
        statisticService = StatisticServiceImplementation()
        showCurrentQuestion()
        configureUI()
    }
    
    private func configureUI() {
        setFontForLabel(textLabel, fontName: "YSDisplay-Bold", fontSize: 23)
        setFontForLabel(counterLabel, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForButton(yesButton, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForButton(noButton, fontName: "YSDisplay-Medium", fontSize: 20)
    }
    
    // MARK: - UI Configuration
    
    private func setFontForLabel(_ label: UILabel, fontName: String, fontSize: CGFloat) {
        label.font = UIFont(name: fontName, size: fontSize)
    }
    
    private func setFontForButton(_ button: UIButton, fontName: String, fontSize: CGFloat) {
        button.titleLabel?.font = UIFont(name: fontName, size: fontSize)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.show(quiz: viewModel)
            }, completion: nil)
        }
    }
    
    // MARK: - Question Handling
    
    private func showCurrentQuestion() {
        guard let factory = questionFactory else { return }
        factory.requestNextQuestion()
    }
    
    private func processAnswer(_ answer: Bool) {
        guard yesButton.isEnabled, noButton.isEnabled else { return }
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - Display Logic
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        changeStateButtons(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            changeStateButtons(isEnabled: true)
            if self.currentQuestionIndex < self.questionsAmount - 1 {
                self.currentQuestionIndex += 1
                self.showCurrentQuestion()
            } else {
                self.showFinalResult()
            }
        }
    }
    
    private func showFinalResult() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        let statisticsText = getStatisticsText()
        let messagePrefix = correctAnswers == questionsAmount ?
        "Поздравляем, вы ответили на 10 из 10!" :
        "Ваш результат: \(correctAnswers)/10"
        let finalMessage = "\(messagePrefix)\n\(statisticsText)"
        let model = AlertModel(title: "Этот раунд окончен!", message: finalMessage, buttonText: "Сыграть ещё раз") { [weak self] in
            self?.resetQuiz()
        }
        alertPresenter.showAlert(model: model)
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showCurrentQuestion()
    }
    private func getStatisticsText() -> String {
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
    private func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

}


