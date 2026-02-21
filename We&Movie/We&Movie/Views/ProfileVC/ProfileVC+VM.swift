//
//  ProfileVC+VM.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 16/1/26.
//

import Foundation

extension ProfileVC {
    class VM: BaseVM {
        func logout() {
            LoginService.shared.logout()
        }
    }
}
