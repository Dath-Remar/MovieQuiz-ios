import XCTest
@testable import MovieQuiz


class MockStatisticService: StatisticService {
    var totalAccuracy: Double = 0
    var gamesCount: Int = 0
    var bestGame: GameRecord = GameRecord(correct: 0, total: 0, date: Date())
    
    func store(correct count: Int, total amount: Int) {
        
    }
}


class MovieQuizPresenterTests: XCTestCase {
    
    var presenter: MovieQuizPresenter!
    var mockStatisticService: MockStatisticService!
    
    override func setUp() {
        super.setUp()
        
        mockStatisticService = MockStatisticService()
        presenter = MovieQuizPresenter(statisticService: mockStatisticService)
    }
    
    override func tearDown() {
        
        presenter = nil
        mockStatisticService = nil
        super.tearDown()
    }
    
    
    func testConvertMethod() {
        // Создание тестовых данных
        let dummyImageData = UIImage(named: "testImage")?.pngData() ?? Data()
        let dummyQuestion = QuizQuestion(image: dummyImageData, text: "Is this a test?", correctAnswer: true)
        
        
        let result = presenter.convert(model: dummyQuestion)
        
        
        XCTAssertEqual(result.question, "Is this a test?", "Текст вопроса должен быть передан без изменений")
        XCTAssertEqual(result.questionNumber, "1/10", "Номер вопроса должен соответствовать ожидаемому формату")
        XCTAssertNotNil(result.image, "Изображение должно быть успешно создано из данных")
    }
    
    
}
