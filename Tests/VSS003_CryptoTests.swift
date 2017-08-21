//
//  VSS003_CryptoTests.swift
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 10/17/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import Foundation
import VirgilSDK
import XCTest

class VSS003_CryptoTests: XCTestCase {
    private var crypto: VSSCrypto!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.crypto = VSSCrypto(defaultKeyType: .EC_BP512R1)
    }
    
    override func tearDown() {
        self.crypto = nil
        
        super.tearDown()
    }
    
    // MARK: Encryption tests
    
    func testED001_EncryptRandomData_SingleCorrectKey_ShouldDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair = self.crypto.generateKeyPair()
        
        let encryptedData = try! self.crypto.encrypt(data, for: [keyPair.publicKey])
        
        let decryptedData = try! self.crypto.decrypt(encryptedData, with: keyPair.privateKey)
        
        XCTAssert(data == decryptedData)
    }
    
    func testED002_EncryptRandomData_SingleIncorrectKey_ShouldNotDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair = self.crypto.generateKeyPair()
        let wrongKeyPair = self.crypto.generateKeyPair()
        
        let encryptedData = try! self.crypto.encrypt(data, for: [keyPair.publicKey])
        
        let decryptedData = try? self.crypto.decrypt(encryptedData, with: wrongKeyPair.privateKey)
        
        XCTAssert(decryptedData == nil)
    }
    
    func testED003_EncryptRandomData_TwoCorrectKeys_ShouldDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair1 = self.crypto.generateKeyPair()
        let keyPair2 = self.crypto.generateKeyPair()
        
        let encryptedData = try! self.crypto.encrypt(data, for: [keyPair1.publicKey, keyPair2.publicKey])
        
        let decryptedData1 = try! self.crypto.decrypt(encryptedData, with: keyPair1.privateKey)
        let decryptedData2 = try! self.crypto.decrypt(encryptedData, with: keyPair2.privateKey)
        
        XCTAssert(data == decryptedData1)
        XCTAssert(data == decryptedData2)
    }
    
    func testES001_EncryptRandomDataStream_SingleCorrectKey_ShouldDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair = self.crypto.generateKeyPair()
        
        let inputStreamForEncryption = InputStream(data: data)
        let outputStreamForEncryption = OutputStream.toMemory()
        
        try! self.crypto.encrypt(inputStreamForEncryption, to: outputStreamForEncryption, for: [keyPair.publicKey])
        
        let encryptedDataProperty = outputStreamForEncryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let encryptedData = encryptedDataProperty as? Data else {
            XCTFail("No encrypted data")
            return
        }
        
        let inputStreamForDecryption = InputStream(data: encryptedData)
        let outputStreamForDecryption = OutputStream.toMemory()
        
        try! self.crypto.decrypt(inputStreamForDecryption, to: outputStreamForDecryption, with: keyPair.privateKey)
        
        let decryptedDataProperty = outputStreamForDecryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let decryptedData = decryptedDataProperty as? Data else {
            XCTFail("No decrypted data")
            return
        }
        
        XCTAssert(data == decryptedData)
    }
    
    func testES002_EncryptRandomDataStream_SingleIncorrectKey_ShouldNotDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair = self.crypto.generateKeyPair()
        let wrongKeyPair = self.crypto.generateKeyPair()
        
        let inputStreamForEncryption = InputStream(data: data)
        let outputStreamForEncryption = OutputStream.toMemory()
        
        try! self.crypto.encrypt(inputStreamForEncryption, to: outputStreamForEncryption, for: [keyPair.publicKey])
        
        let encryptedDataProperty = outputStreamForEncryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let encryptedData = encryptedDataProperty as? Data else {
            XCTFail("No encrypted data")
            return
        }
        
        let inputStreamForDecryption = InputStream(data: encryptedData)
        let outputStreamForDecryption = OutputStream.toMemory()
        
        var errorWasThrown = false
        do {
            try self.crypto.decrypt(inputStreamForDecryption, to: outputStreamForDecryption, with: wrongKeyPair.privateKey)
        }
        catch {
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
        
        let decryptedDataProperty = outputStreamForDecryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let decryptedData = decryptedDataProperty as? Data else {
            XCTFail("No decrypted data")
            return
        }
        
        XCTAssert(decryptedData.count == 0)
    }
    
    func testES003_EncryptRandomDataStream_TwoCorrectKeys_ShouldDecrypt() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair1 = self.crypto.generateKeyPair()
        let keyPair2 = self.crypto.generateKeyPair()
        
        let inputStreamForEncryption = InputStream(data: data)
        let outputStreamForEncryption = OutputStream.toMemory()
        
        try! self.crypto.encrypt(inputStreamForEncryption, to: outputStreamForEncryption, for: [keyPair1.publicKey, keyPair2.publicKey])
        
        let encryptedDataProperty = outputStreamForEncryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let encryptedData = encryptedDataProperty as? Data else {
            XCTFail("No encrypted data")
            return
        }
        
        let inputStreamForDecryption1 = InputStream(data: encryptedData)
        let outputStreamForDecryption1 = OutputStream.toMemory()
        
        try! self.crypto.decrypt(inputStreamForDecryption1, to: outputStreamForDecryption1, with: keyPair1.privateKey)
        
        let decryptedDataProperty1 = outputStreamForDecryption1.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let decryptedData1 = decryptedDataProperty1 as? Data else {
            XCTFail("No decrypted data")
            return
        }
        
        XCTAssert(data == decryptedData1)
        
        let inputStreamForDecryption2 = InputStream(data: encryptedData)
        let outputStreamForDecryption2 = OutputStream.toMemory()
        
        try! self.crypto.decrypt(inputStreamForDecryption2, to: outputStreamForDecryption2, with: keyPair2.privateKey)
        
        let decryptedDataProperty2 = outputStreamForDecryption2.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let decryptedData2 = decryptedDataProperty2 as? Data else {
            XCTFail("No decrypted data")
            return
        }
        
        XCTAssert(data == decryptedData2)
    }
    
    func testES004_EncryptFileDataStream_SingleCorrectKey_ShouldDecrypt() {
        let testFileURL = Bundle(for: type(of: self)).url(forResource: "testData", withExtension: "txt")!
        let inputStreamForEncryption = InputStream(url: testFileURL)!
        
        let keyPair = self.crypto.generateKeyPair()
        
        let outputStreamForEncryption = OutputStream.toMemory()
        
        try! self.crypto.encrypt(inputStreamForEncryption, to: outputStreamForEncryption, for: [keyPair.publicKey])
        
        let encryptedDataProperty = outputStreamForEncryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let encryptedData = encryptedDataProperty as? Data else {
            XCTFail("No encrypted data")
            return
        }
        
        let inputStreamForDecryption = InputStream(data: encryptedData)
        let outputStreamForDecryption = OutputStream.toMemory()
        
        try! self.crypto.decrypt(inputStreamForDecryption, to: outputStreamForDecryption, with: keyPair.privateKey)
        
        let decryptedDataProperty = outputStreamForDecryption.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey)
        
        guard let decryptedData = decryptedDataProperty as? Data else {
            XCTFail("No decrypted data")
            return
        }
        
        let decryptedString = String(data: decryptedData, encoding: .utf8)
        
        XCTAssert(decryptedString == "Hello, Bob!\n")
    }
    
    // MARK: Signatures tests
    func testSD001_SignRandomData_CorrectKeys_ShouldValidate() {
        let data = UUID().uuidString.data(using: .utf8)!

        let keyPair = self.crypto.generateKeyPair()
        
        let signature = try! self.crypto.generateSignature(for: data, with: keyPair.privateKey)
        
        try! self.crypto.verify(data, withSignature: signature, using: keyPair.publicKey)
    }
    
    func testSD002_SignRandomData_IncorrectKeys_ShouldNotValidate() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let keyPair = self.crypto.generateKeyPair()
        let wrongKeyPair = self.crypto.generateKeyPair()
        
        let signature = try! self.crypto.generateSignature(for: data, with: keyPair.privateKey)
        
        var errorWasThrown = false
        do {
            try self.crypto.verify(data, withSignature: signature, using: wrongKeyPair.publicKey)
        }
        catch {
            errorWasThrown = true
        }
        XCTAssert(errorWasThrown)
    }
    
    func testESD001_SignThenEncryptRandomData_CorrectKeys_ShouldDecryptValidate() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let senderKeyPair = self.crypto.generateKeyPair()
        let receiverKeyPair = self.crypto.generateKeyPair()
        
        let signedThenEncryptedData = try! self.crypto.signThenEncrypt(data, with: senderKeyPair.privateKey, for: [receiverKeyPair.publicKey])
        
        let decryptedThenVerifiedData = try! self.crypto.decryptThenVerify(signedThenEncryptedData, with: receiverKeyPair.privateKey, using: senderKeyPair.publicKey)
        
        XCTAssert(data == decryptedThenVerifiedData)
    }
    
    func testESD002_SignThenEncryptRandomData_TwoKeys_ShouldDecryptValidate() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let senderKeyPair = self.crypto.generateKeyPair()
        let oneMoreKeyPair = self.crypto.generateKeyPair()
        let receiverKeyPair = self.crypto.generateKeyPair()
        
        let signedThenEncryptedData = try! self.crypto.signThenEncrypt(data, with: senderKeyPair.privateKey, for: [receiverKeyPair.publicKey])
        
        let decryptedThenVerifiedData = try! self.crypto.decryptThenVerify(signedThenEncryptedData, with: receiverKeyPair.privateKey, usingOneOf: [oneMoreKeyPair.publicKey, senderKeyPair.publicKey])
        
        XCTAssert(data == decryptedThenVerifiedData)
    }
    
    func testESD003_SignThenEncryptRandomData_NoSenderKeys_ShouldNotValidate() {
        let data = UUID().uuidString.data(using: .utf8)!
        
        let senderKeyPair = self.crypto.generateKeyPair()
        let oneMoreKeyPair = self.crypto.generateKeyPair()
        let receiverKeyPair = self.crypto.generateKeyPair()
        
        let signedThenEncryptedData = try! self.crypto.signThenEncrypt(data, with: senderKeyPair.privateKey, for: [receiverKeyPair.publicKey])
        
        var errorWasThrown = false
        do {
            try self.crypto.decryptThenVerify(signedThenEncryptedData, with: receiverKeyPair.privateKey, usingOneOf: [oneMoreKeyPair.publicKey])
        }
        catch {
            errorWasThrown = true
        }
        
        XCTAssert(errorWasThrown)
    }
}
