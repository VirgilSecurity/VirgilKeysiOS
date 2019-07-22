//
// Copyright (C) 2015-2019 Virgil Security Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     (1) Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//
//     (2) Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in
//     the documentation and/or other materials provided with the
//     distribution.
//
//     (3) Neither the name of the copyright holder nor the names of its
//     contributors may be used to endorse or promote products derived from
//     this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>
//

import Foundation

/// Protocol for KeyknoxClient
///
/// See: KeyknoxClient for default implementation
@objc(VSSKeyknoxClientProtocol) public protocol KeyknoxClientProtocol: class {
    /// Push value to Keyknox service
    ///
    /// - Parameters:
    ///   - identities: identities
    ///   - root1: path root1
    ///   - root2: path root2
    ///   - key: key
    ///   - meta: meta data
    ///   - value: encrypted blob
    ///   - previousHash: hash of previous blob
    ///   - overwrite: if true - overwrites identities, if false - complements
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func pushValue(identities: [String],
                         root1: String,
                         root2: String,
                         key: String,
                         meta: Data,
                         value: Data,
                         previousHash: Data?,
                         overwrite: Bool) throws -> EncryptedKeyknoxValue

    /// Pulls values from Keyknox service
    ///
    /// - Parameters:
    ///   - identity: Keyknox owner identity (if nil - access own keyknox)
    ///   - root1: path root1
    ///   - root2: path root2
    ///   - key: key
    /// - Returns: EncryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func pullValue(identity: String?,
                         root1: String,
                         root2: String,
                         key: String) throws -> EncryptedKeyknoxValue

    /// Get keys for given root
    ///
    /// - Parameters:
    ///   - identity: Keyknox owner identity (if nil - access own keyknox)
    ///   - root1: path root1
    ///   - root2: path root2
    /// - Returns: Array of keys
    /// - Throws: Depends on implementation
    @objc func getKeys(identity: String?,
                       root1: String?,
                       root2: String?) throws -> [String]

    /// Resets Keyknox value (makes it empty). Also increments version
    ///
    /// - Parameters:
    ///   - root1: path root1
    ///   - root2: path root2
    ///   - key: key
    /// - Returns: DecryptedKeyknoxValue
    /// - Throws: Depends on implementation
    @objc func resetValue(root1: String?,
                          root2: String?,
                          key: String?) throws -> DecryptedKeyknoxValue
}
