//
//  CreateRoomRequest.swift
//  We&Movie
//

import Foundation

/// Create room request: POST /api/Chat/room
struct CreateRoomRequest: Codable, Sendable {
    let name: String
    let token: Int64  // film token (0 = без фильма)
}
