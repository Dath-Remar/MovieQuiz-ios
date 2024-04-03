import UIKit

// MARK: - AlertPresenter

final class AlertPresenter {
    
    // MARK: - Properties
    
    private weak var viewController: UIViewController?
    
    // MARK: - Initialization
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Public Methods
    
    func showAlert(model: AlertModel) {
        guard let viewController = viewController else {
            return
        }
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
