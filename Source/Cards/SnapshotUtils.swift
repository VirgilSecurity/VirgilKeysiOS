//
//  SnapshotUtils.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/15/17.
//  Copyright © 2017 VirgilSecurity. All rights reserved.
//

import Foundation

class SnapshotUtils {
    public static func takeSnapshot(object: Any) throws -> Data {
        return try JSONSerialization.data(withJSONObject: object, options: [])
    }
    
    public static func takeSnapshot(object: Encodable) throws -> Data {
        return try SnapshotUtils.takeSnapshot(object: object.asJson())
    }
    
    public static func parseSnapshot<T: Decodable>(snapshot: Data) -> T? {
        guard let json = try? JSONSerialization.jsonObject(with: snapshot, options: .allowFragments) else {
            return nil
        }
        
        return T(dict: json)
    }
}
