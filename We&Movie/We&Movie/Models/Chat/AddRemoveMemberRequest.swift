//
//  AddRemoveMemberRequest.swift
//  We&Movie
//

import Foundation

/// Body for add/remove member: PUT .../add-member, .../remove-member
struct AddRemoveMemberRequest: Codable, Sendable {
    let userId: Int
}
