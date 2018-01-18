//
//  Serialization.swift
//  VirgilSDK
//
//  Created by Eugen Pivovarov on 1/17/18.
//  Copyright © 2018 VirgilSecurity. All rights reserved.
//

import Foundation

extension Decodable {
    init?(data: Data) {
        guard let me = try? JSONDecoder().decode(Self.self, from: data) else { return nil }
        self = me
    }
    
    init?(string: String) {
        guard let data = Data(base64Encoded: string) else { return nil }
        self.init(data: data)
    }
    
    init?(dict any: Any) {
        guard let data = try? JSONSerialization.data(withJSONObject: any, options: .prettyPrinted) else { return nil }
        self.init(data: data)
    }
}

extension Encodable {
    func asJson() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
    public func asJsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    public func asString() throws -> String {
        let data = try self.asJsonData()
        return data.base64EncodedString()
    }
}

