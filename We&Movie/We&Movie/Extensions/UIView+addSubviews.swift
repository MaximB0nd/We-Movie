//
//  UIView+addSubviews.swift
//  We&Movie
//
//  Created by Максим Бондарев on 17/1/26.
//

import UIKit

extension UIView {
    func addSubviews(views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
