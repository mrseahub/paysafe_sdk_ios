//
//  OPAYMockCardStore.h
//
//  Created by sachin on 23/02/15.
//  Copyright (c) 2015 opus. All rights reserved.
//
#import <Availability.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import <Foundation/Foundation.h>
#import "PaySafeMockDataStore.h"

@interface PaySafeMockCardStore : NSObject <PaySafeMockDataStore>

@end

#endif