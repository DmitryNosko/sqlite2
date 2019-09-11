//
//  FeedItemRepository.h
//  SQLTest
//
//  Created by USER on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@interface FeedItemRepository : NSObject
//FeedItem
- (FeedItem *) addFeedItem:(FeedItem *) item;
- (NSMutableArray<FeedItem *> *) addFeedItems:(NSMutableArray<FeedItem *>*) items;
- (NSMutableArray<FeedItem *>*) feedItems;
- (void) updateFeedItem:(FeedItem *) item;
- (void) removeFeedItem:(FeedItem *) item;
@end
