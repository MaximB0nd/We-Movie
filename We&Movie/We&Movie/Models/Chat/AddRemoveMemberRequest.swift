//
//  AddRemoveMemberRequest.swift
//  We&Movie
//

import Foundation

/// Body для добавления/удаления участника: PUT .../add-member, .../remove-member
struct AddRemoveMemberRequest: Codable, Sendable {
    let userId: Int
}
