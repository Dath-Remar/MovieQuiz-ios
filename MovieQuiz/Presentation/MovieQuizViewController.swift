import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
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
    
    lazy var alertPresenter = AlertPresenter(viewController: self)
    var statisticService: StatisticService?
    private var presenter = MovieQuizPresenter(statisticService: StatisticServiceImplementation())
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let statisticService = StatisticServiceImplementation()
        self.presenter = MovieQuizPresenter(statisticService: statisticService)
        presenter.viewController = self
        setupQuiz()
    }
    
    // MARK: - Setup
    
    private func setupQuiz() {
        presenter.startQuiz()
        let questionFactory = QuestionFactory(delegate: presenter)
        overrideUserInterfaceStyle = .dark
        statisticService = StatisticServiceImplementation()
        configureUI()
        showLoadingIndicator()
        
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        textLabel.text = ""
        activityIndicator.hidesWhenStopped = true
        questionFactory.loadData(completion: { [weak self] in
            self?.showCurrentQuestion()
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
    
    // MARK: - Question Handling
    
    func showCurrentQuestion() {
        showLoadingIndicator()
        presenter.requestNextQuestion()
    }
    
    func show(quiz step: QuizStepViewModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.masksToBounds = true
            self.imageView.layer.cornerRadius = 20
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            UIView.transition(with: self.textLabel, duration: 1, options: .transitionCrossDissolve, animations: {
                self.textLabel.text = step.question
            })
            UIView.transition(with: self.imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                self.imageView.image = step.image
            })
            self.counterLabel.text = step.questionNumber
        }
    }
    
    func updateUIForAnswer(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        changeStateButtons(isEnabled: false)
    }
    
    func resetQuiz() {
        presenter.resetQuestionIndex()
        presenter.correctAnswers = 0
        showCurrentQuestion()
    }
    
    // MARK: - UI Helpers
    
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK: - ActivityIndicator
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public methods
    
    func handleDataLoadingError(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            self.presenter.handleDataLoadingError(with: error)
        }
    }
}


