//
//  VirgilSDKTestsSwift.swift
//  VirgilSDKTestsSwift
//
//  Created by Oleksandr Deundiak on 10/8/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

import XCTest
import VirgilSDK

/// Each request should be done less than or equal this number of seconds.
let kEstimatedRequestCompletionTime = 5

class VSS001_ClientTests: XCTestCase {
    
    private var client: VSSClient!
    private var crypto: VSSCrypto!
    private var utils: VSSTestUtils!
    private var consts: VSSTestsConst!
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        self.consts = VSSTestsConst()
        self.crypto = VSSCrypto()

        let validator = VSSCardValidator(crypto: self.crypto)
        validator.addVerifier(withId: self.consts.applicationId, publicKey: Data(base64Encoded: self.consts.applicationPublicKeyBase64)!)
        let config = VSSServiceConfig(token: self.consts.applicationToken)
        config.cardValidator = validator
        self.client = VSSClient(serviceConfig: config)
        
        self.utils = VSSTestUtils(crypto: self.crypto, consts: self.consts)
    }
    
    override func tearDown() {
        self.client = nil
        self.crypto = nil
        self.utils = nil
        self.consts = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    func test001_CreateCard() {
        let ex = self.expectation(description: "Virgil Card should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            guard let card = registeredCard else {
                XCTFail("Card is nil")
                return
            }
            
            XCTAssert(self.utils.check(card: card, isEqualToCreateCardRequest: request))
            
            ex.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func test002_CreateCardWithData() {
        let ex = self.expectation(description: "Virgil Card with data should be created")
        
        let numberOfRequests = 1
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest(with: ["custom_key1": "custom_field1", "custom_key2": "custom_field2"])
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            guard let card = registeredCard else {
                XCTFail("Card is nil")
                return
            }
            
            XCTAssert(self.utils.check(card: card, isEqualToCreateCardRequest: request))
            
            ex.fulfill()
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func test003_SearchCards() {
        let ex = self.expectation(description: "Virgil Card should be created. Search should return 1 card which is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            let criteria = VSSSearchCardsCriteria(scope: .application, identityType: registeredCard!.identityType, identities: [registeredCard!.identity])
            
            sleep(1)
            
            self.client.searchCards(using: criteria) { cards, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCards = cards else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCards.count == 1);
                XCTAssert(self.utils.check(card: foundCards[0], isEqualToCard: registeredCard!))
                
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func test004_GetCard() {
        let ex = self.expectation(description: "Virgil Card should be created. Get card request should return 1 card which is equal to created card");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }
            
            sleep(1)
            self.client.getCard(withId: registeredCard!.identifier) { card, error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                guard let foundCard = card else {
                    XCTFail("Found card == nil")
                    return
                }
                
                XCTAssert(foundCard.identifier == registeredCard!.identifier)
                XCTAssert(self.utils.check(card: foundCard, isEqualToCard: registeredCard!))
                
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
    
    func test005_RevokeCard() {
        let ex = self.expectation(description: "Virgil Card should be created. Virgil card should be revoked");
        
        let numberOfRequests = 2
        let timeout = TimeInterval(numberOfRequests * kEstimatedRequestCompletionTime)
        
        let request = self.utils.instantiateCreateCardRequest()
        
        self.client.createCardWith(request) { (registeredCard, error) in
            guard error == nil else {
                XCTFail("Failed: " + error!.localizedDescription)
                return
            }

            let revokeRequest = self.utils.instantiateRevokeCardRequestFor(card: registeredCard!)
            
            sleep(1)
            self.client.revokeCardWith(revokeRequest) { error in
                guard error == nil else {
                    XCTFail("Failed: " + error!.localizedDescription)
                    return
                }
                
                ex.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: timeout) { error in
            guard error == nil else {
                XCTFail("Expectation failed: " + error!.localizedDescription)
                return
            }
        }
    }
}