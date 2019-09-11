//
//  FeedResourceRepository.m
//  SQLTest
//
//  Created by USER on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FeedResourceRepository.h"

@implementation FeedResourceRepository


#pragma mark - FeedResource Requests

- (FeedResource *) addFeedResource:(FeedResource *) resource {
    
    sqlite3_stmt *statement;
    NSInteger lastRowID = 0;
    const char *dbpath = [[self dataBasePath] UTF8String];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK)
    {
        
        NSString *insertFeedResource = [NSString stringWithFormat:@"INSERT INTO FeedResource (name, url) VALUES (\"%@\", \"%@\")", resource.name, resource.url.absoluteString];
        const char *insert_stmt = [insertFeedResource UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            lastRowID = sqlite3_last_insert_rowid(rssDataBase);
            resource.identifier = lastRowID;
            NSLog(@"FeedResource added");
        } else {
            NSLog(@"Failed to add FeedResource");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resource;
}


- (void) removeFeedResource:(FeedResource *) resource {
    
    const char *dbpath = [[self dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK)
    {
        NSString *quetyToRemove = [NSString stringWithFormat: @"DELETE FROM FeedResource WHERE FeedResource.id = \"%@\"", @(resource.identifier)];
        
        const char *remove_stmt = [quetyToRemove UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, remove_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"FeedResource removed");
        } else {
            NSLog(@"Failed to remove FeedResource");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
}

- (NSMutableArray<FeedResource *>*) feedResources {
    
    const char *dbpath = [[self dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedResource *>* resources = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        NSString *getFeedResources = [NSString stringWithFormat: @"SELECT ID, name, url FROM FeedResource"];
        
        const char *query_stmt = [getFeedResources UTF8String];
        
        
        if (sqlite3_prepare_v2(rssDataBase, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *identifier = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString *name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSURL* url = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)]];
                
                [resources addObject:[[FeedResource alloc] initWithID:identifier.integerValue name:name url:url]];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resources;
@end
