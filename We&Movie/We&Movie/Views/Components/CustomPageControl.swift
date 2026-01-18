//
//  CustomPageControl.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

class CustomPageControl: UIView {
    
    // MARK: - Properties
    var numberOfPages: Int = 0 {
        didSet {
            setupIndicators()
            invalidateIntrinsicContentSize()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateCurrentPage()
        }
    }
    
    var pageIndicatorTintColor: UIColor = .systemGray {
        didSet {
            updateIndicatorsColors()
        }
    }
    
    var currentPageIndicatorTintColor: UIColor = .systemCyan {
        didSet {
            updateIndicatorsColors()
        }
    }
    
    // MARK: - Private Properties
    private var indicators: [UIView] = []
    private let indicatorSize: CGFloat = 10
    private let currentIndicatorWidth: CGFloat = 30
    private let currentIndicatorHeight: CGFloat = 10
    private let spacing: CGFloat = 8
    private var indicatorConstraints: [Int: [NSLayoutConstraint]] = [:]
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
    }
    
    private func setupIndicators() {
        // Удаляем старые индикаторы
        indicators.forEach { $0.removeFromSuperview() }
        indicators.removeAll()
        indicatorConstraints.removeAll()
        
        guard numberOfPages > 0 else { return }
        
        // Создаем индикаторы для всех страниц
        for index in 0..<numberOfPages {
            let indicator = UIView()
            indicator.layer.cornerRadius = indicatorSize / 2
            indicator.translatesAutoresizingMaskIntoConstraints = false
            addSubview(indicator)
            indicators.append(indicator)
            
            // Начальные constraints
            indicatorConstraints[index] = [
                indicator.widthAnchor.constraint(equalToConstant: indicatorSize),
                indicator.heightAnchor.constraint(equalToConstant: indicatorSize),
                indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
            
            if index == 0 {
                indicatorConstraints[index]?.append(
                    indicator.leadingAnchor.constraint(equalTo: leadingAnchor)
                )
            } else {
                let previousIndicator = indicators[index - 1]
                indicatorConstraints[index]?.append(
                    indicator.leadingAnchor.constraint(equalTo: previousIndicator.trailingAnchor, constant: spacing)
                )
            }
        }
        
        // Активируем все constraints
        indicatorConstraints.values.forEach { NSLayoutConstraint.activate($0) }
        
        // Обновляем цвета и текущую страницу
        updateIndicatorsColors()
        updateCurrentPage()
    }
    
    private func updateCurrentPage() {
        guard currentPage >= 0 && currentPage < indicators.count else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [weak self] in
            guard let self = self else { return }
            
            // Обновляем цвета (без анимации для цветов)
            self.updateIndicatorsColors()
            
            // Обновляем размеры для всех индикаторов
            for (index, indicator) in self.indicators.enumerated() {
                let isCurrentPage = index == self.currentPage
                let width = isCurrentPage ? self.currentIndicatorWidth : self.indicatorSize
                let height = isCurrentPage ? self.currentIndicatorHeight : self.indicatorSize
                let cornerRadius = isCurrentPage ? self.currentIndicatorHeight / 2 : self.indicatorSize / 2
                
                // Обновляем constraints
                if let widthConstraint = self.indicatorConstraints[index]?.first(where: { $0.firstAttribute == .width }) {
                    widthConstraint.constant = width
                }
                if let heightConstraint = self.indicatorConstraints[index]?.first(where: { $0.firstAttribute == .height }) {
                    heightConstraint.constant = height
                }
                
                // Обновляем внешний вид
                indicator.layer.cornerRadius = cornerRadius
            }
            
            self.layoutIfNeeded()
        }
    }
    
    private func updateIndicatorsColors() {
        for (index, indicator) in indicators.enumerated() {
            // Пройденные страницы (индекс меньше текущей) - pageIndicatorTintColor
            // Текущая и непройденные (индекс >= текущей) - currentPageIndicatorTintColor
            if index < currentPage {
                // Пройденная страница
                indicator.backgroundColor = pageIndicatorTintColor
            } else {
                // Текущая или непройденная страница
                indicator.backgroundColor = currentPageIndicatorTintColor
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard numberOfPages > 0 else {
            return CGSize(width: 0, height: currentIndicatorHeight)
        }
        
        // Рассчитываем ширину с учетом вытянутого индикатора
        let totalWidth = CGFloat(numberOfPages) * indicatorSize
            + CGFloat(numberOfPages - 1) * spacing
            + (currentIndicatorWidth - indicatorSize) // Добавляем разницу для вытянутого индикатора
        
        let height = max(indicatorSize, currentIndicatorHeight)
        return CGSize(width: totalWidth, height: height)
    }
    
    // MARK: - Public Methods
    func setCurrentPage(_ page: Int, animated: Bool = true) {
        if animated {
            currentPage = page
        } else {
            UIView.performWithoutAnimation {
                currentPage = page
            }
        }
    }
}
