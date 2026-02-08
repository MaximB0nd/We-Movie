//
//  AlertProvider.swift
//  We&Movie
//

import UIKit

/// Единая точка показа ошибок/сообщений через алерт.
final class AlertProvider {

    static let shared = AlertProvider()

    private init() {}

    func show(error: Error, title: String = "Ошибка", on viewController: UIViewController? = nil) {
        show(message: message(from: error), title: title, on: viewController)
    }

    func show(message: String, title: String = "Ошибка", on viewController: UIViewController? = nil) {
        DispatchQueue.main.async {
            guard let presenter = viewController ?? self.topViewController() else { return }

            if presenter.presentedViewController is UIAlertController {
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default))
            presenter.present(alert, animated: true)
        }
    }

    private func message(from error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.userMessage
        }
        if let localized = error as? LocalizedError, let description = localized.errorDescription {
            return description
        }
        return error.localizedDescription
    }

    private func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = scenes.flatMap { $0.windows }
        let keyWindow = windows.first(where: { $0.isKeyWindow })
        return topViewController(from: keyWindow?.rootViewController)
    }

    private func topViewController(from root: UIViewController?) -> UIViewController? {
        if let nav = root as? UINavigationController {
            return topViewController(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(from: presented)
        }
        return root
    }
}
