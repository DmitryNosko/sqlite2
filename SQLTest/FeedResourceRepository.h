//
//  FeedResourceRepository.h
//  SQLTest
//
//  Created by USER on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResource.h"

@interface FeedResourceRepository : NSObject
//FeedResource
- (FeedResource *) addFeedResource:(FeedResource *) resource;
- (void) removeFeedResource:(FeedResource *) resource;
- (NSMutableArray<FeedResource *>*) feedResources;

@end
