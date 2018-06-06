//
// Copyright (C) 2015-2018 Virgil Security Inc.
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

#import "VSSKeyStorageConfiguration.h"

@interface VSSKeyStorageConfiguration ()

- (instancetype __nonnull)initWithAccessibility:(NSString * __nullable)accessibility accessGroup:(NSString * __nullable)accessGroup namePrefix:(NSString * __nullable)namePrefix NS_DESIGNATED_INITIALIZER;

@end

@implementation VSSKeyStorageConfiguration

- (instancetype)init {
    return [self initWithAccessibility:nil accessGroup:nil namePrefix:nil];
}

- (instancetype)initWithAccessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup namePrefix:(NSString *)namePrefix {
    self = [super init];
    if (self) {
        _accessibility = accessibility.length == 0 ? (__bridge NSString*)kSecAttrAccessibleWhenUnlocked : [accessibility copy];
        _accessGroup = [accessGroup copy];
        _applicationName = [NSBundle.mainBundle.bundleIdentifier copy];
        _namePrefix = namePrefix.length == 0 ? @"" : [namePrefix copy];
    }
    
    return self;
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithDefaultValues {
    return [[VSSKeyStorageConfiguration alloc] init];
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithAccessibility:(NSString *)accessibility accessGroup:(NSString *)accessGroup {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:accessibility accessGroup:accessGroup namePrefix:nil];
}

+ (VSSKeyStorageConfiguration *)keyStorageConfigurationWithNamePrefix:(NSString *)namePrefix {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:nil accessGroup:nil namePrefix:namePrefix];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[VSSKeyStorageConfiguration alloc] initWithAccessibility:self.accessibility accessGroup:self.accessGroup namePrefix:self.namePrefix];
}

@end
