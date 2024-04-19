import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.handleNoButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.handleYesButtonClicked()
    }
    // MARK: - IBOutlet
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var question: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private Properties
    
    //  private var currentQuestionIndex = 0
   // var correctAnswers = 0
    //  private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
   // var currentQuestion: QuizQuestion?
    lazy var alertPresenter = AlertPresenter(viewController: self)
    var statisticService: StatisticService?
    private var presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuiz()
        presenter.viewController = self // Устанавливаем ссылку на ViewController в Presenter

    }
    
    // MARK: - Setup
    private func setupQuiz() {
       // questionFactory.delegate = presenter
        let questionFactory = QuestionFactory(delegate: presenter)  // Создание фабрики вопросов
        self.questionFactory = questionFactory
        overrideUserInterfaceStyle = .dark  // Установка стиля интерфейса
        statisticService = StatisticServiceImplementation()  // Инициализация сервиса статистики
        configureUI()  // Настройка UI
        showLoadingIndicator()  // Показ индикатора загрузки

        imageView.layer.cornerRadius = 20  // Настройка внешнего вида imageView
        imageView.backgroundColor = .clear  // Установка фона imageView
        textLabel.text = ""  // Сброс текста метки
        activityIndicator.hidesWhenStopped = true  // Установка поведения индикатора
        // Загрузка данных с коллбэком для отображения вопроса
        questionFactory.loadData(completion: { [weak self] in
            self?.showCurrentQuestion()  // Вызов метода для отображения вопроса после загрузки данных
        })
    }
    private func configureUI() {
        setFontForLabel(question, fontName: "YSDisplay-Medium", fontSize: 20)
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
    
   /* // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.hideLoadingIndicator()
            guard let question = question else {
                return
            }
            self.presenter.currentQuestion = question
            let viewModel = self.presenter.convert(model: question)
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.show(quiz: viewModel)
            })
        }
    }*/
    // MARK: - Question Handling
    
    func showCurrentQuestion() {
        guard let factory = questionFactory else { return }
        showLoadingIndicator()
        factory.requestNextQuestion()
    }
    
 /*   func processAnswer(_ answer: Bool) {
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
    */
    // MARK: - Display Logic
    /*
     private func convert(model: QuizQuestion) -> QuizStepViewModel {
     return QuizStepViewModel(
     image: UIImage(data: model.image) ?? UIImage(),
     question: model.text,
     questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
     )
     } */
    
    func show(quiz step: QuizStepViewModel) {
        DispatchQueue.main.async { [weak self] in  // Гарантируем, что UI обновляется в главном потоке
            guard let self = self else { return }
            
            // Настройка визуальных свойств imageView
            self.imageView.layer.masksToBounds = true
            self.imageView.layer.cornerRadius = 20
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            
            // Анимированное обновление текста вопроса и изображения
            UIView.transition(with: self.textLabel, duration: 1, options: .transitionCrossDissolve, animations: {
                self.textLabel.text = step.question  // Устанавливаем текст вопроса
            })
            
            UIView.transition(with: self.imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                self.imageView.image = step.image  // Устанавливаем изображение
            })
            
            // Установка текста номера вопроса без анимации
            self.counterLabel.text = step.questionNumber
        }
    }
    
   /* func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        changeStateButtons(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            changeStateButtons(isEnabled: true)
            if self.presenter.isLastQuestion(){
                presenter.showFinalResult()
                //presenter.switchToNextQuestion()
                //self.showCurrentQuestion()
            } else {
                //self.showFinalResult()
                self.presenter.switchToNextQuestion()
                self.showCurrentQuestion()
            }
        }
    }
    */
    
    func updateUIForAnswer(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        changeStateButtons(isEnabled: false) // Отключаем кнопки, пока идёт задержка
    }
    // MARK: - Results Handling
    
 /*   private func showFinalResult() {
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let statisticsText = getStatisticsText()
        let messagePrefix = presenter.correctAnswers == presenter.questionsAmount ?
        "Поздравляем, вы ответили на 10 из 10!" :
        "Ваш результат: \(presenter.correctAnswers)/10"
        let finalMessage = "\(messagePrefix)\n\(statisticsText)"
        let model = AlertModel(title: "Этот раунд окончен!", message: finalMessage, buttonText: "Сыграть ещё раз") { [weak self] in
            self?.resetQuiz()
        }
        alertPresenter.showAlert(model: model)
    }
    */
    func resetQuiz() {
        presenter.resetQuestionIndex()
        presenter.correctAnswers = 0
        showCurrentQuestion()
    }
    
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
    
    // MARK: - UI Helpers
    
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK: - AlertError
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            presenter.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showAlert(model: model)
    }
    
    // MARK: - ActivityIndicator
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public methods
   /*
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    */
    func handleDataLoadingError(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            let model = AlertModel(
                title: "Ошибка",
                message: error.localizedDescription,
                buttonText: "Попробовать еще раз") { [weak self] in
                    guard let self = self else { return }
                    self.resetQuiz()
                    self.showLoadingIndicator()
                    self.questionFactory?.loadData(completion: {
                        self.showCurrentQuestion()  // Показать текущий вопрос после повторной загрузки данных
                    })
                }
            self.alertPresenter.showAlert(model: model)
        }
    }
    /*func didFailToLoadData(with error: Error) {
        handleDataLoadingError(with: error)
    }
    
    func didReceiveError(error: Error) {
        handleDataLoadingError(with: error)
    }*/
    /*
    func didReceiveQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question = question else {
            return
        }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
     */
}


