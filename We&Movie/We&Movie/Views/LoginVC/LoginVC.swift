//
//  LoginVC.swift
//  We&Movie
//

import UIKit

class LoginVC: BaseVC {

    private let viewModel: VM
    private weak var coordinator: AuthCoordinator?

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let logoView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "LogoWithText")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Авторизация"
        label.font = .systemFont(ofSize: 26, weight: .regular)
        label.textAlignment = .center
        label.textColor = .accentBlueMuted
        return label
    }()
    
    private let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email / Никнейм"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .accentBlue
        return label
    }()

    private let loginTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email или никнейм"
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.backgroundColor = .accentWhite
        field.layer.cornerRadius = 24
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.accentBlueMuted.cgColor
        return field
    }()

    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .accentBlue
        return label
    }()

    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.backgroundColor = .accentWhite
        field.layer.cornerRadius = 24
        field.isSecureTextEntry = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = .newPassword
        field.translatesAutoresizingMaskIntoConstraints = false
        field.layer.borderWidth = 2
        field.layer.borderColor = UIColor.accentBlueMuted.cgColor
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .accentBlue
        button.setTitleColor(.accentWhite, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет аккаунта?  Регистрация", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.accentBlue, for: .normal)
        return button
    }()

    private lazy var loginFieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loginTitleLabel, loginTextField])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private lazy var passwordFieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [passwordTitleLabel, passwordTextField])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private lazy var formStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loginFieldStack, passwordFieldStack])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    init(coordinator: AuthCoordinator) {
        self.viewModel = VM()
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var keyboardHeight: CGFloat = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        subscribeToKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboard()
    }

    override func setupUI() {
        super.setupUI()

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStack)

        configureTextField(loginTextField, rightView: nil, fieldHeight: 50)
        configureTextField(passwordTextField, rightView: makePasswordToggle(), fieldHeight: 50)

        contentStack.addArrangedSubview(logoView)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(formStack)
        contentStack.addArrangedSubview(loginButton)
        contentStack.addArrangedSubview(registerButton)

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            logoView.heightAnchor.constraint(equalToConstant: 250),
            logoView.widthAnchor.constraint(lessThanOrEqualTo: contentStack.widthAnchor),
            logoView.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),

            loginTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }

    @objc private func loginTapped() {
        let login = loginTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        guard validate(login: login, password: password) else { return }

        setLoading(true)
        Task { [weak self] in
            do {
                _ = try await self?.viewModel.login(emailOrNickname: login, password: password)
                await MainActor.run {
                    self?.setLoading(false)
                    self?.coordinator?.showMainTabBar()
                }
            } catch {
                await MainActor.run {
                    self?.setLoading(false)
                    self?.showError(error)
                }
            }
        }
    }

    @objc private func registerTapped() {
        coordinator?.showRegister(
            transitionType: .fade,
        )
    }

    private func configureTextField(_ field: UITextField, rightView: UIView?, fieldHeight: CGFloat) {
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        field.leftViewMode = .always
        field.returnKeyType = .done
        field.delegate = self
        field.inputAssistantItem.trailingBarButtonGroups = []
        
        if let rightView = rightView {
            rightView.isUserInteractionEnabled = true
            
            let padding: CGFloat = 12
            let rightViewSize = rightView.bounds.size == .zero ? CGSize(width: 36, height: 36) : rightView.bounds.size
            let containerWidth = rightViewSize.width + padding * 2
            let containerHeight = fieldHeight
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
            container.isUserInteractionEnabled = true
            
            rightView.frame = CGRect(
                x: (containerWidth - rightViewSize.width) / 2,
                y: (containerHeight - rightViewSize.height) / 2,
                width: rightViewSize.width,
                height: rightViewSize.height
            )
            
            container.addSubview(rightView)
            field.rightView = container
            field.rightViewMode = .always
        }
    }

    private func makePasswordToggle() -> UIView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .accentBlue
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        if let button = passwordTextField.rightView?.subviews.first as? UIButton {
            UIView.animate(withDuration: 0.3) {
                button.setImage(UIImage(systemName: imageName), for: .normal)
            }
        }
        
    }

    private func validate(login: String, password: String) -> Bool {
        if login.isEmpty {
            showMessage("Введите email или никнейм")
            return false
        }

        if password.isEmpty {
            showMessage("Введите пароль")
            return false
        }

        return true
    }

    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        loginButton.alpha = isLoading ? 0.6 : 1.0
    }

    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func unsubscribeFromKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        keyboardHeight = frame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) { [weak self] in
            self?.scrollView.contentInset.bottom = self?.keyboardHeight ?? 0
            self?.scrollView.verticalScrollIndicatorInsets.bottom = self?.keyboardHeight ?? 0
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        keyboardHeight = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.scrollView.contentInset.bottom = 0
            self?.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    private func scrollToTextField(_ textField: UITextField) {
        let rectInContent = contentView.convert(textField.bounds, from: textField)
        let padding: CGFloat = 24
        var targetRect = rectInContent.insetBy(dx: 0, dy: -padding)
        targetRect.size.height += padding * 2
        scrollView.scrollRectToVisible(targetRect, animated: true)
    }

}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scrollToTextField(textField)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
