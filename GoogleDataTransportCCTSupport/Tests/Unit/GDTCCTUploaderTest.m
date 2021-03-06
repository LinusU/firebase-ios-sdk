/*
 * Copyright 2019 Google
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

#import <XCTest/XCTest.h>

#import "Library/Private/GDTCCTNanopbHelpers.h"
#import "Library/Private/GDTCCTUploader.h"

#import "Tests/Unit/Helpers/GDTCCTEventGenerator.h"
#import "Tests/Unit/TestServer/GDTCCTTestServer.h"

@interface GDTCCTUploaderTest : XCTestCase

/** An event generator for testing. */
@property(nonatomic) GDTCCTEventGenerator *generator;

/** The local HTTP server to use for testing. */
@property(nonatomic) GDTCCTTestServer *testServer;

@end

@implementation GDTCCTUploaderTest

- (void)setUp {
  self.generator = [[GDTCCTEventGenerator alloc] init];
  self.testServer = [[GDTCCTTestServer alloc] init];
  [self.testServer registerLogBatchPath];
  [self.testServer start];
  XCTAssertTrue(self.testServer.isRunning);
}

- (void)tearDown {
  [super tearDown];
  [self.generator deleteGeneratedFilesFromDisk];
  [self.testServer stop];
}

- (void)testUploadGivenConditions {
  NSArray<GDTStoredEvent *> *storedEventsA = [self.generator generateTheFiveConsistentStoredEvents];
  NSSet<GDTStoredEvent *> *storedEvents = [NSSet setWithArray:storedEventsA];

  GDTUploadPackage *package = [[GDTUploadPackage alloc] init];
  package.events = storedEvents;
  GDTCCTUploader *uploader = [[GDTCCTUploader alloc] init];
  uploader.serverURL = [self.testServer.serverURL URLByAppendingPathComponent:@"logBatch"];
  __weak id weakSelf = self;
  XCTestExpectation *responseSentExpectation = [self expectationWithDescription:@"response sent"];
  self.testServer.responseCompletedBlock =
      ^(GCDWebServerRequest *_Nonnull request, GCDWebServerResponse *_Nonnull response) {
        // Redefining the self var addresses strong self capturing in the XCTAssert macros.
        id self = weakSelf;
        XCTAssertNotNil(self);
        [responseSentExpectation fulfill];
        XCTAssertEqual(response.statusCode, 200);
        XCTAssertTrue(response.hasBody);
      };
  XCTestExpectation *uploadExpectation = [self expectationWithDescription:@"upload completes"];
  [uploader uploadPackage:package
               onComplete:^(GDTTarget target, GDTClock *_Nonnull nextUploadAttemptUTC,
                            NSError *_Nullable uploadError) {
                 [uploadExpectation fulfill];
                 XCTAssertTrue(nextUploadAttemptUTC.timeMillis > [GDTClock snapshot].timeMillis);
               }];
  [self waitForExpectations:@[ responseSentExpectation, uploadExpectation ] timeout:30.0];
  dispatch_sync(uploader.uploaderQueue, ^{
    XCTAssertNil(uploader.currentTask);
  });
}

@end
