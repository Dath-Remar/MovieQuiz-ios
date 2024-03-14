import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // Структура для вопроса квиза

    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    // Модель данных для отображения вопроса

    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    // Модель данных для результатов квиза

    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    // Массив вопросов для квиза
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    
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
    @IBAction private func yesButton(_ sender: UIButton) {
        processAnswer(true)
    }
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var question: UILabel!
    
    
    // Функция для настройки шрифта и размера текста лэйблов.
    func setFontForLabel(_ label: UILabel, fontName: String, fontSize: CGFloat) {
        label.font = UIFont(name: fontName, size: fontSize)
    }
    
    // Функция для настройки шрифта и размера текста кнопок.
    func setFontForButton(_ button: UIButton, fontName: String, fontSize: CGFloat) {
        button.titleLabel?.font = UIFont(name: fontName, size: fontSize)
    }

    
    // Обработка ответа пользователя

    private func processAnswer(_ answer: Bool) {
        guard yesButton.isEnabled, noButton.isEnabled else { return }  // Проверка, что кнопки активны
        
        let currentQuestion = questions[currentQuestionIndex]
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
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
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
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
        
        yesButton.isEnabled = false    // Деактивация кнопок
        noButton.isEnabled = false
        // Отложенный переход к следующему вопросу или результатам

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            
            if self.currentQuestionIndex < self.questions.count - 1 {
                self.currentQuestionIndex += 1
                self.showCurrentQuestion()
            } else {
                self.showFinalResult()
            }
        }
    }

    // Отображение текущего вопроса

    private func showCurrentQuestion() {
            let currentQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: currentQuestion)
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {      // Добавление анимации перехода между вопросами
            self.show(quiz: viewModel)
        }, completion: nil)
        }
    // Показ окончательных результатов квиза

    private func showFinalResult() {
           let resultViewModel = QuizResultsViewModel(
               title: "Раунд окончен!",
               text: "Ваш результат \(correctAnswers) из \(questions.count)",
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

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
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
    
    

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
