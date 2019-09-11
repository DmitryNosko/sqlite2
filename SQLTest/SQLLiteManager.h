//
//  SQLLiteManager.h
//  SQLTest
//
//  Created by Dzmitry Noska on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedResource.h"
#import "FeedItem.h"
#import <sqlite3.h>

@interface SQLLiteManager : NSObject {
    sqlite3* rssDataBase;
}

+ (instancetype) sharedSQLLiteManager;
- (void) createDB;

//FeedItem
- (FeedItem *) addFeedItem:(FeedItem *) item;
- (NSMutableArray<FeedItem *> *) addFeedItems:(NSMutableArray<FeedItem *>*) items;
- (NSMutableArray<FeedItem *>*) feedItems;
- (void) updateFeedItem:(FeedItem *) item;
- (void) removeFeedItem:(FeedItem *) item;

//FeedResource
- (void) addFeedResource:(FeedResource *) resource;
- (void) removeFeedResource:(FeedResource *) resource;
- (NSMutableArray<FeedResource *>*) feedResources;

@end

