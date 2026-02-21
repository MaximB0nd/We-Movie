//
//  FirstLaunchStorage.swift
//  We&Movie
//
//  Created by Maxim Bondarev on 9/2/26.
//

import Foundation

/// Stores the fact of first launch/onboarding completion.
final class FirstLaunchStorage: Sendable {

    static let shared = FirstLaunchStorage()

    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isFirstLaunch: Bool {
        !userDefaults.bool(forKey: hasCompletedOnboardingKey)
    }

    func markOnboardingCompleted() {
        userDefaults.set(true, forKey: hasCompletedOnboardingKey)
    }
}
