/*
 * Copyright 2018 Google
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

#import <GoogleDataTransport/GDTTransformer.h>

@class GDTStorage;

NS_ASSUME_NONNULL_BEGIN

@interface GDTTransformer ()

/** The queue on which all work will occur. */
@property(nonatomic) dispatch_queue_t eventWritingQueue;

/** The storage instance used to store events. Should only be used to inject a testing fake. */
@property(nonatomic) GDTStorage *storageInstance;

/** If YES, every call to -transformEvent will result in a background task. */
@property(nonatomic, readonly) BOOL runningInBackground;

@end

NS_ASSUME_NONNULL_END
