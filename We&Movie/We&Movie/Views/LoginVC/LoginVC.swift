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
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.textColor = .accentBlueMuted
        return label
    }()

    private let loginTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email или никнейм"
        field.font = .systemFont(ofSize: 16, weight: .regular)
        field.backgroundColor = .accentWhite
        field.layer.cornerRadius = 18
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = .username
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
        let stack = UIStackView(arrangedSubviews: [loginTextField])
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

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
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
            
            logoView.heightAnchor.constraint(equalToConstant: 250),
            logoView.widthAnchor.constraint(lessThanOrEqualTo: contentStack.widthAnchor),
            logoView.centerXAnchor.constraint(equalTo: contentStack.centerXAnchor),

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

    private func configureTextField(_ field: UITextField, rightView: UIView?) {
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.returnKeyType = .done
        field.delegate = self
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

}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
