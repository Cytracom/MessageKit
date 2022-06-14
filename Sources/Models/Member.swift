/*
 MIT License

 Copyright (c) 2017-2020 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

open class GroupMember: Codable {
    public let name_last: String
    public let name_first: String
    public let email: String
    public let did: String
    public let user_id: String
    open var left_thread: Bool
    open var is_shared: Bool?
    
    public init(lastName: String, firstName: String, email: String, did: String, userId: String, leftThread: Bool, isShared: Bool) {
        self.name_last = lastName
        self.name_first = firstName
        self.email = email
        self.did = did
        self.user_id = userId
        self.left_thread = leftThread
        self.is_shared = isShared
    }
}

public struct ThreadMember: Codable {
    public let did: String
    public let cnam: String
    
    public init(did: String, cnam: String) {
        self.did = did
        self.cnam = cnam
    }
}

public struct Member: Codable {
    public let type: String
    public let member: Any?
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case type
        case member
    }
    
    public init(member: ThreadMember) {
        self.type = "did"
        self.member = member
    }
    
    public init(member: GroupMember) {
        self.type = "user"
        self.member = member
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        if let decode = Member.decoders[type] {
            member = try decode(container)
        } else {
            member = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        if let cid = self.member {
            guard let encode = Member.encoders[type] else {
                let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid attachment: \(type).")
                throw EncodingError.invalidValue(self, context)
            }
            try encode(cid, &container)
        } else {
            try container.encodeNil(forKey: .member)
        }
    }
    
    // MARK: Registration
    
    private typealias MessageDecoder = (KeyedDecodingContainer<CodingKeys>) throws -> Any
    private typealias MessageEncoder = (Any, inout KeyedEncodingContainer<CodingKeys>) throws -> Void
    
    private static var decoders: [String: MessageDecoder] = [:]
    private static var encoders: [String: MessageEncoder] = [:]
    
    public static func register<A: Codable>(_ type: A.Type, for typeName: String) {
        decoders[typeName] = { container in
            try container.decode(A.self, forKey: .member)
        }
        
        encoders[typeName] = { payload, container in
            try container.encode(payload as! A, forKey: .member)
        }
    }
}
