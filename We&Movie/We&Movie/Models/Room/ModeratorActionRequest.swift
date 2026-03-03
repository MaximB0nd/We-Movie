//
//  ModeratorActionRequest.swift
//  We&Movie
//

import Foundation

/// Grant/revoke moderator: PUT .../grant-moderator, .../revoke-moderator
struct ModeratorActionRequest: Codable, Sendable {
    let userId: Int
}
