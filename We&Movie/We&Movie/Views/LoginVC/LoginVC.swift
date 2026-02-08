//
//  LoginVC.swift
//  We&Movie
//

import UIKit

class LoginVC: BaseVC {

    private let viewModel: VM
    private weak var coordinator: AuthCoordinator?

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

    private let logoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 180
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Авторизация"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .accentBlueMuted
        return label
    }()

    private enum LoginMode {
        case email
        case nickname
    }

    private var loginMode: LoginMode = .email {
        didSet {
            updateLoginMode()
        }
    }

    private let emailModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Email", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.accentBlue, for: .normal)
        button.backgroundColor = .accentWhite
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.accentBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nicknameModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Никнейм", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.accentBlue, for: .normal)
        button.backgroundColor = .accentWhite
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.accentBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var loginModeStack: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        let separator = UILabel()
        separator.text = "/"
        separator.textColor = .accentBlueMuted
        separator.font = .systemFont(ofSize: 20, weight: .bold)
        let stack = UIStackView(arrangedSubviews: [emailModeButton, separator, nicknameModeButton, spacer])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()

    private let loginTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "user"
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.backgroundColor = .accentWhite
        field.layer.cornerRadius = 18
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Пароль"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .accentBlue
        return label
    }()

    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "password"
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.backgroundColor = .accentWhite
        field.layer.cornerRadius = 18
        field.isSecureTextEntry = true
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = .password
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .accentBlue
        button.setTitleColor(.accentWhite, for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let forgotButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Забыли пароль?", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(.accentCyan, for: .normal)
        return button
    }()

    private let bottomPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет аккаунта?"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .accentBlue
        return label
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.accentBlue, for: .normal)
        return button
    }()

    private lazy var loginFieldStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loginModeStack, loginTextField])
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

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bottomPromptLabel, registerButton])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.distribution = .equalCentering
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func setupUI() {
        super.setupUI()

        view.addSubview(contentView)
        contentView.addSubview(contentStack)

        configureTextField(loginTextField, rightView: nil)
        configureTextField(passwordTextField, rightView: makePasswordToggle())

        contentStack.addArrangedSubview(logoView)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(formStack)
        contentStack.addArrangedSubview(loginButton)
        contentStack.addArrangedSubview(forgotButton)
        contentStack.addArrangedSubview(bottomStack)

        emailModeButton.addTarget(self, action: #selector(emailModeTapped), for: .touchUpInside)
        nicknameModeButton.addTarget(self, action: #selector(nicknameModeTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        updateLoginMode()
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            

            logoView.heightAnchor.constraint(equalToConstant: 60),
            logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor),
            logoView.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),

            emailModeButton.heightAnchor.constraint(equalToConstant: 24),
            nicknameModeButton.heightAnchor.constraint(equalTo: emailModeButton.heightAnchor),
            loginTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            loginButton.heightAnchor.constraint(equalToConstant: 52)
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

    @objc private func forgotTapped() {
        let alert = UIAlertController(title: "Скоро будет", message: "Восстановление пароля в разработке.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    @objc private func registerTapped() {
        coordinator?.showRegister()
    }

    @objc private func emailModeTapped() {
        loginMode = .email
    }

    @objc private func nicknameModeTapped() {
        loginMode = .nickname
    }

    private func configureTextField(_ field: UITextField, rightView: UIView?) {
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.returnKeyType = .done
        field.delegate = self
        field.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        field.inputAssistantItem.leadingBarButtonGroups = [
            UIBarButtonItemGroup(barButtonItems: [keyboardTextItem], representativeItem: nil)
        ]
        field.inputAssistantItem.trailingBarButtonGroups = []
        if let rightView {
            field.rightView = rightView
            field.rightViewMode = .always
        }
    }

    private func makePasswordToggle() -> UIView {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .accentBlue
        button.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        (passwordTextField.rightView as? UIButton)?.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func validate(login: String, password: String) -> Bool {
        if login.isEmpty {
            let message = loginMode == .email ? "Введите email" : "Введите никнейм"
            showMessage(message)
            return false
        }

        if password.isEmpty {
            showMessage("Введите пароль")
            return false
        }

        return true
    }

    private func updateLoginMode() {
        switch loginMode {
        case .email:
            applySelectedStyle(to: emailModeButton, selected: true)
            applySelectedStyle(to: nicknameModeButton, selected: false)
            loginTextField.placeholder = "mail@example.com"
            loginTextField.keyboardType = .emailAddress
            loginTextField.textContentType = .username
        case .nickname:
            applySelectedStyle(to: emailModeButton, selected: false)
            applySelectedStyle(to: nicknameModeButton, selected: true)
            loginTextField.placeholder = "me001"
            loginTextField.keyboardType = .default
            loginTextField.textContentType = .username
        }
    }

    private func applySelectedStyle(to button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = .accentBlue
            button.setTitleColor(.accentWhite, for: .normal)
            button.layer.borderColor = UIColor.accentBlue.cgColor
        } else {
            button.backgroundColor = .accentWhite
            button.setTitleColor(.accentBlue, for: .normal)
            button.layer.borderColor = UIColor.accentBlue.cgColor
        }
    }

    private func setLoading(_ isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        loginButton.alpha = isLoading ? 0.6 : 1.0
    }

}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
