//
//  MainVC.swift
//  We&Movie
//
//  Created by Максим Бондарев on 16/1/26.
//

import UIKit

class MainVC: BaseVC {

    private weak var coordinator: MainCoordinator?
    private var vm: VM
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        self.vm = VM()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    }
}
