import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
   
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
         
        overrideUserInterfaceStyle = .dark
        print(NSHomeDirectory())
        print(Bundle.main.bundlePath) 
        // Показываем текущий вопрос квиза на экране.
        showCurrentQuestion()
        
        setFontForLabel(textLabel, fontName: "YSDisplay-Bold", fontSize: 23)
        setFontForLabel(counterLabel, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForLabel(question, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForButton(yesButton, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForButton(noButton, fontName: "YSDisplay-Medium", fontSize: 20)
    }
    
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
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            // Здесь может быть код для обработки ситуации, когда вопросы закончились или произошла ошибка
            return
        }
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Использование UIView.transition для плавного перехода
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                // В этом блоке animations вы обновляете пользовательский интерфейс новыми данными
                self.show(quiz: viewModel)
            }, completion: nil)
        }
    }
    // Отображение текущего вопроса
    
    private func showCurrentQuestion() {
        guard let factory = questionFactory else { return }
        factory.requestNextQuestion()
    }
    
    // Функция для настройки шрифта и размера текста лэйблов.
    // Сделал их приватными
    private func setFontForLabel(_ label: UILabel, fontName: String, fontSize: CGFloat) {
        label.font = UIFont(name: fontName, size: fontSize)
    }
    
    // Функция для настройки шрифта и размера текста кнопок.
    private func setFontForButton(_ button: UIButton, fontName: String, fontSize: CGFloat) {
        button.titleLabel?.font = UIFont(name: fontName, size: fontSize)
    }
    
    
    // Обработка ответа пользователя
    
    private func processAnswer(_ answer: Bool) {
        guard yesButton.isEnabled, noButton.isEnabled else { return }  // Проверка, что кнопки активны
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = answer == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
        }
        
        showAnswerResult(isCorrect: isCorrect)
    }
    // Конвертация модели вопроса в модель для отображения
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    // Отображение данных вопроса
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = UIColor.clear.cgColor
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
    }
    
    // Показ результатов ответа
    
    private func showAnswerResult(isCorrect: Bool) {
        
        imageView.layer.borderWidth = 8
        
        
        
        // Использование цветов кастомных из макета : YP Green и YP Red
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        
        yesButton.isEnabled = false    // Деактивация кнопок
        noButton.isEnabled = false
        // Отложенный переход к следующему вопросу или результатам
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            
            if self.currentQuestionIndex < self.questionsAmount - 1 {
                self.currentQuestionIndex += 1
                self.showCurrentQuestion()
            } else {
                self.showFinalResult()
            }
        }
    }
    

        // Показ окончательных результатов квиза
        
    private func showFinalResult() {
        let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

        let model = AlertModel(title: "Раунд окончен!", message: text, buttonText: "Сыграть ещё раз") { [weak self] in
            self?.resetQuiz()
        }
        alertPresenter.showAlert(model: model)
    }

        // Сброс квиза и начало нового раунда
        
     private func resetQuiz() {
            currentQuestionIndex = 0
            correctAnswers = 0
            showCurrentQuestion()
        }
    }

