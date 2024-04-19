import XCTest
@testable import MovieQuiz

// Моковый класс для StatisticService
class MockStatisticService: StatisticService {
    var totalAccuracy: Double = 0
    var gamesCount: Int = 0
    var bestGame: GameRecord = GameRecord(correct: 0, total: 0, date: Date())

    func store(correct count: Int, total amount: Int) {
        // Здесь можно добавить логику для отслеживания вызовов или тестирования интеракций
    }
}

// Класс тестов для MovieQuizPresenter
class MovieQuizPresenterTests: XCTestCase {
    
    var presenter: MovieQuizPresenter!
    var mockStatisticService: MockStatisticService!
    
    override func setUp() {
        super.setUp()
        // Инициализация мока и презентера
        mockStatisticService = MockStatisticService()
        presenter = MovieQuizPresenter(statisticService: mockStatisticService)
    }

    override func tearDown() {
        // Очистка после каждого теста
        presenter = nil
        mockStatisticService = nil
        super.tearDown()
    }
    
    // Тестирование метода convert
    func testConvertMethod() {
        // Создание тестовых данных
        let dummyImageData = UIImage(named: "testImage")?.pngData() ?? Data()
        let dummyQuestion = QuizQuestion(image: dummyImageData, text: "Is this a test?", correctAnswer: true)
        
        // Вызов тестируемого метода
        let result = presenter.convert(model: dummyQuestion)
        
        // Проверки
        XCTAssertEqual(result.question, "Is this a test?", "Текст вопроса должен быть передан без изменений")
        XCTAssertEqual(result.questionNumber, "1/10", "Номер вопроса должен соответствовать ожидаемому формату")
        XCTAssertNotNil(result.image, "Изображение должно быть успешно создано из данных")
    }
    
    // Можно добавить дополнительные тесты для других методов
}
