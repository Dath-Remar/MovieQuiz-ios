import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Принудительно устанавливаем темный стиль интерфейса для этого вью контроллера.
        // Это изменит цвет системных элементов UI, например, статус бара на белый,
        // если фон вашего приложения темный.
        overrideUserInterfaceStyle = .dark
        
        // Показываем текущий вопрос квиза на экране.
        showCurrentQuestion()
        
        // Настраиваем шрифт и размер для текстовых меток и кнопок.
        setFontForLabel(textLabel, fontName: "YSDisplay-Bold", fontSize: 23)
        setFontForLabel(counterLabel, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForLabel(question, fontName: "YSDisplay-Medium", fontSize: 20)
        
        setFontForButton(yesButton, fontName: "YSDisplay-Medium", fontSize: 20)
        setFontForButton(noButton, fontName: "YSDisplay-Medium", fontSize: 20)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        processAnswer(false)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        processAnswer(true)
    }
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var question: UILabel!
    
    
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
    
    // Отображение текущего вопроса
    
    private func showCurrentQuestion() {
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {      // Добавление анимации перехода между вопросами
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }, completion: nil)
        }
    }
        // Показ окончательных результатов квиза
        
    private func showFinalResult() {
            let resultViewModel = QuizResultsViewModel(
                title: "Раунд окончен!",
                text: "Ваш результат \(correctAnswers) из \(questionsAmount)",
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: resultViewModel)
        }
        // Отображение алерта с результатами квиза
        
    private func show(quiz result: QuizResultsViewModel) {
            let alert = UIAlertController(
                title: result.title,
                message: result.text,
                preferredStyle: .alert
            )
            // Действие для кнопки в алерте
            
            let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.resetQuiz()
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        // Сброс квиза и начало нового раунда
        
     private func resetQuiz() {
            currentQuestionIndex = 0
            correctAnswers = 0
            showCurrentQuestion()
        }
    }

