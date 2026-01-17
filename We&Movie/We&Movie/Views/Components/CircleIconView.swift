//
//  CircleIconView.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

class CircleIconView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    private func setupView() {
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            iconImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5)
        ])
    }
    
    func configure(backgroundColor: UIColor, iconName: String? = nil, iconImage: UIImage? = nil, assetImageName: String? = nil, iconColor: UIColor) {
        self.backgroundColor = backgroundColor
        if let assetImageName = assetImageName {
            iconImageView.image = UIImage(named: assetImageName)
            iconImageView.tintColor = nil
        } else if let iconName = iconName {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.tintColor = iconColor
        } else if let iconImage = iconImage {
            iconImageView.image = iconImage
            iconImageView.tintColor = iconColor
        }
    }
}
