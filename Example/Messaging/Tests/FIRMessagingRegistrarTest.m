/*
 * Copyright 2017 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "FIRMessagingPubSubRegistrar.h"
#import "FIRMessagingRegistrar.h"
#import "FIRMessagingUtilities.h"
#import "NSError+FIRMessaging.h"

static NSString *const kFIRMessagingUserDefaultsSuite =
    @"FIRMessagingRegistrarTestUserDefaultsSuite";

static NSString *const kDeviceAuthId = @"12345";
static NSString *const kSecretToken = @"45657809";
static NSString *const kVersionInfo = @"1.0";
static NSString *const kTopicToSubscribeTo = @"/topics/xyz/hello-world";
static NSString *const kFIRMessagingAppIDToken = @"abcdefgh1234lmno";
static NSString *const kSubscriptionID = @"sample-subscription-id-xyz";

@interface FIRMessagingRegistrar ()

@property(nonatomic, readwrite, strong) FIRMessagingPubSubRegistrar *pubsubRegistrar;

@end

@interface FIRMessagingRegistrarTest : XCTestCase

@property(nonatomic, readwrite, strong) FIRMessagingRegistrar *registrar;
@property(nonatomic, readwrite, strong) id mockRegistrar;
@property(nonatomic, readwrite, strong) id mockPubsubRegistrar;

@end

@implementation FIRMessagingRegistrarTest

- (void)setUp {
  [super setUp];
  _registrar = [[FIRMessagingRegistrar alloc] init];
  _mockRegistrar = OCMPartialMock(_registrar);
  _registrar.pubsubRegistrar = OCMClassMock([FIRMessagingPubSubRegistrar class]);
  _mockPubsubRegistrar = _registrar.pubsubRegistrar;
}

- (void)testUpdateSubscriptionWithValidCheckinData {
  [self.registrar updateSubscriptionToTopic:kTopicToSubscribeTo
                                  withToken:kFIRMessagingAppIDToken
                                    options:nil
                               shouldDelete:NO
                                    handler:^(NSError *error){
                                    }];

  OCMVerify([self.mockPubsubRegistrar updateSubscriptionToTopic:[OCMArg isEqual:kTopicToSubscribeTo]
                                                      withToken:[OCMArg isEqual:kFIRMessagingAppIDToken]
                                                        options:nil
                                                   shouldDelete:NO
                                                        handler:OCMOCK_ANY]);
}

- (void)testUpdateSubscription {
  __block FIRMessagingTopicOperationCompletion pubsubCompletion;
  [[[self.mockPubsubRegistrar stub] andDo:^(NSInvocation *invocation) {
    pubsubCompletion(nil);
  }] updateSubscriptionToTopic:kTopicToSubscribeTo
                     withToken:kFIRMessagingAppIDToken
                       options:nil
                  shouldDelete:NO
                       handler:[OCMArg checkWithBlock:^BOOL(id obj) {
                         return (pubsubCompletion = obj) != nil;
                       }]];

  [self.registrar updateSubscriptionToTopic:kTopicToSubscribeTo
                                  withToken:kFIRMessagingAppIDToken
                                    options:nil
                               shouldDelete:NO
                                    handler:^(NSError *error) {
                                      XCTAssertNil(error);
                                    }];
}
@end
