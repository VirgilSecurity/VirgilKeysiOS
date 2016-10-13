//
//  VSSCrypto.m
//  VirgilSDK
//
//  Created by Oleksandr Deundiak on 9/29/16.
//  Copyright © 2016 VirgilSecurity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSCrypto.h"
#import "VSSCryptoPrivate.h"
#import "VSSKeyPairPrivate.h"
#import "VSSPublicKeyPrivate.h"
#import "VSSPrivateKeyPrivate.h"
#import "VSCHash.h"

@import VirgilCrypto;

@implementation VSSCrypto

#pragma mark - Key processing

- (VSSKeyPair *)generateKeyPair {
    VSCKeyPair *keyPair = [[VSCKeyPair alloc] init];
    
    NSData *keyPairId = [self computeHashForPublicKey:keyPair.publicKey];
    if ([keyPairId length] == 0)
        return nil;
    
    VSSPrivateKey *privateKey = [[VSSPrivateKey alloc] initWithKey:keyPair.privateKey identifier:keyPairId];
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:keyPair.publicKey identifier:keyPairId];
    
    return [[VSSKeyPair alloc] initWithPrivateKey:privateKey publicKey:publicKey];
}

- (VSSPrivateKey *)importPrivateKey:(NSData *)privateKey password:(NSString *)password {
    if ([privateKey length] == 0)
        return nil;

    NSData *privateKeyData = ([password length] == 0) ?
        [VSCKeyPair privateKeyToDER:privateKey] : [VSCKeyPair decryptPrivateKey:privateKey privateKeyPassword:password];
    
    if ([privateKeyData length] == 0)
        return nil;

    NSData *publicKey = [VSCKeyPair extractPublicKeyWithPrivateKey:privateKeyData privateKeyPassword:nil];
    if ([publicKey length] == 0)
        return nil;

    NSData *keyIdentifier = [self computeHashForPublicKey:publicKey];
    if ([keyIdentifier length] == 0)
        return nil;
    
    NSData *exportedPrivateKeyData = [VSCKeyPair privateKeyToDER:privateKeyData];
    if ([exportedPrivateKeyData length] == 0)
        return nil;
    
    VSSPrivateKey *prKey = [[VSSPrivateKey alloc] initWithKey:exportedPrivateKeyData identifier:keyIdentifier];
    
    return prKey;
}

- (VSSPublicKey *)importPublicKey:(NSData *)publicKey {
    NSData *keyIdentifier = [self computeHashForPublicKey:publicKey];
    if ([publicKey length] == 0)
        return nil;

    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:publicKey];
    if ([exportedPublicKey length] == 0)
        return nil;
    
    VSSPublicKey *pubKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:keyIdentifier];
    if (publicKey == nil)
        return nil;
    
    return pubKey;
}

- (NSData *)exportPrivateKey:(VSSPrivateKey *)privateKey password:(NSString *)password {
    if ([password length] == 0)
        return [VSCKeyPair privateKeyToDER:privateKey.key];
    
    NSData *encryptedPrivateKeyData = [VSCKeyPair encryptPrivateKey:privateKey.key privateKeyPassword:password];
    
    return [VSCKeyPair privateKeyToDER:encryptedPrivateKeyData privateKeyPassword:password];
}

- (NSData *)exportPublicKey:(VSSPublicKey *)publicKey {
    return [VSCKeyPair publicKeyToDER:publicKey.key];
}

- (VSSPublicKey *)extractPublicKeyFromPrivateKey:(VSSPrivateKey *)privateKey {
    NSData *publicKeyData = [VSCKeyPair extractPublicKeyWithPrivateKey:privateKey.key privateKeyPassword:nil];
    if ([publicKeyData length] == 0)
        return nil;
    
    NSData *exportedPublicKey = [VSCKeyPair publicKeyToDER:publicKeyData];
    if ([exportedPublicKey length] == 0)
        return nil;
    
    VSSPublicKey *publicKey = [[VSSPublicKey alloc] initWithKey:exportedPublicKey identifier:privateKey.identifier];
    
    return publicKey;
}

#pragma mark - Data processing

- (NSData *)encryptData:(NSData *)data forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];
    
    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKey.key error:&error];
        
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return nil;
        }
    }

    NSData *encryptedData = [cipher encryptData:data embedContentInfo:YES error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }

    return encryptedData;
}

- (BOOL)encryptStream:(NSInputStream *)stream outputStream:(NSOutputStream *)outputStream forRecipients:(NSArray<VSSPublicKey *> *)recipients error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    for (VSSPublicKey *publicKey in recipients) {
        [cipher addKeyRecipient:publicKey.identifier publicKey:publicKey.key error:&error];
        if (error != nil) {
            if (errorPtr != nil)
                *errorPtr = error;
            return NO;
        }
    }

    [cipher encryptDataFromStream:stream toStream:outputStream error:&error];
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return YES;
}

- (BOOL)verifyData:(NSData *)data signature:(NSData *)signature signerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    BOOL verified = [signer verifySignature:signature data:data publicKey:signerPublicKey.key error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (BOOL)verifyStream:(NSInputStream *)stream signature:(NSData *)signature signerPublicKey:(VSSPublicKey *)signerPublicKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    BOOL verified = [signer verifySignature:signature fromStream:stream publicKey:signerPublicKey.key error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return verified;
}

- (NSData *)decryptData:(NSData *)data privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCCryptor *cipher = [[VSCCryptor alloc] init];

    NSError *error;
    NSData *decryptedData = [cipher decryptData:data recipientId:privateKey.identifier privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return decryptedData;
}

- (BOOL)decryptStream:(NSInputStream *)stream outputStream:(NSOutputStream *)outputStream privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCChunkCryptor *cipher = [[VSCChunkCryptor alloc] init];

    NSError *error;
    [cipher decryptFromStream:stream toStream:outputStream recipientId:privateKey.identifier privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return NO;
    }
    
    return YES;
}

- (NSData *)signatureForData:(NSData *)data privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCSigner *signer = [[VSCSigner alloc] init];
    
    NSError *error;
    NSData *signature = [signer signData:data privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (NSData *)signatureForStream:(NSInputStream *)stream privateKey:(VSSPrivateKey *)privateKey error:(NSError **)errorPtr {
    VSCStreamSigner *signer = [[VSCStreamSigner alloc] init];
    
    NSError *error;
    NSData *signature = [signer signStreamData:stream privateKey:privateKey.key keyPassword:nil error:&error];
    
    if (error != nil) {
        if (errorPtr != nil)
            *errorPtr = error;
        return nil;
    }
    
    return signature;
}

- (VSSFingerprint * __nonnull)calculateFingerprintForData:(NSData * __nonnull)data {
    NSData *hash = [self computeHashForData:data withAlgorithm:VSSHashAlgorithmSHA256];
    return [[VSSFingerprint alloc] initWithValue:hash];
}

- (NSData * __nonnull)computeHashForData:(NSData * __nonnull)data withAlgorithm:(VSSHashAlgorithm)algorithm {
    VSCHashAlgorithm cryptoAlgorithm;
    switch (algorithm) {
        case VSSHashAlgorithmMD5: cryptoAlgorithm = VSCHashAlgorithmMD5; break;
        case VSSHashAlgorithmSHA1: cryptoAlgorithm = VSCHashAlgorithmSHA1; break;
        case VSSHashAlgorithmSHA224: cryptoAlgorithm = VSCHashAlgorithmSHA224; break;
        case VSSHashAlgorithmSHA256: cryptoAlgorithm = VSCHashAlgorithmSHA256; break;
        case VSSHashAlgorithmSHA384: cryptoAlgorithm = VSCHashAlgorithmSHA384; break;
        case VSSHashAlgorithmSHA512: cryptoAlgorithm = VSCHashAlgorithmSHA512; break;
    }
    VSCHash *hash = [[VSCHash alloc] initWithAlgorithm:cryptoAlgorithm];
    return [hash hash:data];
}

- (NSData *)computeHashForPublicKey:(NSData *)publicKey {
    NSData *publicKeyDER = [VSCKeyPair publicKeyToDER:publicKey];
    return [self computeHashForData:publicKeyDER withAlgorithm:VSSHashAlgorithmSHA256];
}

@end
