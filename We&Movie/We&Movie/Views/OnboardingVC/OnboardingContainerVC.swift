//
//  OnboardingContainerVC.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import UIKit

class OnboardingContainerVC: BaseVC {
    
    private let viewModel: VM
    private weak var coordinator: OnboardingCoordinator?
    
    private let pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        return pageVC
    }()
    
    private let pageControl: CustomPageControl = {
        let pageControl = CustomPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .accentGreen
        pageControl.currentPageIndicatorTintColor = .accentPink
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Далее", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
        button.backgroundColor = .accentPink
        button.setTitleColor(.accentWhite, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пропустить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .regular)
        button.setTitleColor(.accentBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var pages: [OnboardingPageVC] = []
    private var currentPageIndex: Int = 0
    
    init(coordinator: OnboardingCoordinator) {
        self.viewModel = VM()
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        
        setupPages()
        setupPageViewController()
        
        view.addSubview(pageViewController.view)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        updateButtons()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            nextButton.heightAnchor.constraint(equalToConstant: 70),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            skipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupPages() {
        for i in 0..<3 {
            let page = OnboardingPageVC(pageIndex: i, totalPages: 3, coordinator: coordinator!)
            pages.append(page)
        }
    }
    
    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
        }
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
    
    private func updateButtons() {
        if currentPageIndex == pages.count - 1 {
            nextButton.setTitle("Начать", for: .normal)
            skipButton.isHidden = true
        } else {
            nextButton.setTitle("Далее", for: .normal)
            skipButton.isHidden = false
        }
        pageControl.currentPage = currentPageIndex
    }
    
    @objc private func nextButtonTapped() {
        if currentPageIndex < pages.count - 1 {
            currentPageIndex += 1
            let nextPage = pages[currentPageIndex]
            pageViewController.setViewControllers([nextPage], direction: .forward, animated: true)
            updateButtons()
        } else {
            coordinator?.showAuth()
        }
    }
    
    @objc private func skipButtonTapped() {
        coordinator?.showAuth()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingContainerVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingPageVC),
              currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingPageVC),
              currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingContainerVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let currentVC = pageViewController.viewControllers?.first as? OnboardingPageVC,
           let index = pages.firstIndex(of: currentVC) {
            currentPageIndex = index
            updateButtons()
        }
    }
}
