//
//  SQLLiteManager.m
//  SQLTest
//
//  Created by Dzmitry Noska on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "SQLLiteManager.h"

@interface SQLLiteManager()
@property (strong, nonatomic) NSFileManager* fileManager;
@end


@implementation SQLLiteManager

static SQLLiteManager* shared;

+(instancetype) sharedSQLLiteManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [SQLLiteManager new];
        shared.fileManager = [NSFileManager defaultManager];
    });
    return shared;
}

#pragma mark - CreateDB

- (NSString *) dataBasePath {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"rssDataBase.db"];
}

- (void) createDB {
    //NSLog(@"path = %@", [self dataBasePath]);
    if ([self.fileManager fileExistsAtPath:[self dataBasePath]] == NO) {
        const char *dbpath = [[self dataBasePath] UTF8String];
        
        if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
            char *errMsg = nil;
            
            const char *sql_stmt_FeedResource = "CREATE TABLE IF NOT EXISTS FeedResource (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, url TEXT)";
            [self createTable:sql_stmt_FeedResource errMsg:errMsg];
            
            const char *sql_stmt_FeedItem = "CREATE TABLE IF NOT EXISTS FeedItem (ID INTEGER PRIMARY KEY AUTOINCREMENT, itemTitle TEXT, link TEXT, pubDate DATETIME, itemDescription TEXT, enclousure TEXT, imageURL TEXT, isFavorite BOOL NOT NULL DEFAULT 0, isReaded BOOL NOT NULL DEFAULT 0, isAvailable BOOL NOT NULL DEFAULT 0, resourceURL TEXT, resourceID INTEGER, FOREIGN KEY (resourceID) REFERENCES FeedResource(id))";
            [self createTable:sql_stmt_FeedItem errMsg:errMsg];
            
            
            sqlite3_close(rssDataBase);
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }
}

#pragma mark - Table Requests

- (void) createTable:(const char*) sql_stmt errMsg:(char *) errorMsg {
    if (sqlite3_exec(rssDataBase, sql_stmt, NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"Failed to create table");
        NSLog(@"state = %@", @(sql_stmt));
    } else {
        NSLog(@"Successful");
    }
}

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
}

#pragma mark - FeedItem Requests

- (FeedItem *) addFeedItem:(FeedItem *) item {//TODO lastinsertrowid

    sqlite3_stmt *statement;
    NSInteger lastRowID = 0;
    const char *dbpath = [[self dataBasePath] UTF8String];

    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK)
    {

        NSString *insertFeedItem = [NSString stringWithFormat:
                                        @"INSERT INTO FeedItem (itemTitle, link, pubDate, itemDescription, enclousure, imageURL, isFavorite, isReaded, isAvailable, resourceURL, resourceID) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                                        item.itemTitle,
                                        item.link,
                                        item.pubDate,
                                        item.itemDescription,
                                        item.enclosure,
                                        item.imageURL,
                                        @(item.isFavorite),
                                        @(item.isReaded),
                                        @(item.isAvailable),
                                        item.resourceURL,
                                        @(item.resource.identifier)
                                        ];
        const char *insert_stmt = [insertFeedItem UTF8String];
    
        sqlite3_prepare_v2(rssDataBase, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            lastRowID = sqlite3_last_insert_rowid(rssDataBase);
            item.identifier = lastRowID;
            NSLog(@"FeedItem added");
        } else {
            NSLog(@"Failed to add FeedItem");
        }

        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return item;
}

- (NSMutableArray<FeedItem *> *) addFeedItems:(NSMutableArray<FeedItem *>*) items {

    NSMutableArray<FeedItem *>* resultItems = [[NSMutableArray alloc] init];
    for (FeedItem* item in items) {
        [resultItems addObject:[self addFeedItem:item]];
    }
    
    return resultItems;
}

- (void) updateFeedItem:(FeedItem *) item {
    
    sqlite3_stmt *statement;
    
    const char *dbpath = [[self dataBasePath] UTF8String];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK)
    {
        
        NSString *updateFeedItem = [NSString stringWithFormat:
                                    @"UPDATE FeedItem SET isFavorite = \"%@\", isReaded = \"%@\", isAvailable = \"%@\" WHERE ID = \"%@\"", @(item.isFavorite), @(item.isReaded), @(item.isAvailable), @(item.identifier)];
        const char *insert_stmt = [updateFeedItem UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            sqlite3_reset(statement);
        }
    }
}

- (NSMutableArray<FeedItem *>*) feedItems {
    
    const char *dbpath = [[self dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    NSMutableArray<FeedItem *>* resources = [NSMutableArray array];
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK) {
        
        NSString *getFeedItems = [NSString stringWithFormat: @"SELECT fi.ID, fi.itemTitle, fi.link, fi.pubDate, fi.itemDescription, fi.enclousure, fi.imageURL, fi.isFavorite, fi.isReaded, fi.isAvailable, fi.resourceURL, fr.ID, fr.name, fr.url FROM FeedItem AS fi JOIN FeedResource AS fr ON fi.resourceID = fr.ID;"];
        
        const char *query_stmt = [getFeedItems UTF8String];
        
        if (sqlite3_prepare_v2(rssDataBase, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSInteger itemID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)].integerValue;
                NSString *itemTitle = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSMutableString* link = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSDate *pubDate = [self dateFromString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)]];
                NSMutableString *itemDescription = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                NSString *enclousure = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSString *imageURL = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                BOOL isFavorite = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] boolValue];
                BOOL isReaded = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] boolValue];
                BOOL isAvailable = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] boolValue];
                NSURL *resourceURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)]];
                
                NSInteger resourceID = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)].integerValue;
                NSString *resourceName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)];
                NSURL *resURL = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)]];
                
                FeedResource* resource = [[FeedResource alloc] initWithID:resourceID name:resourceName url:resURL];
                FeedItem* item = [[FeedItem alloc] initWithID:itemID itemTitle:itemTitle link:link pubDate:pubDate itemDescription:itemDescription enclosure:enclousure imageURL:imageURL isFavorite:isFavorite isReaded:isReaded isAvailable:isAvailable resourceURL:resourceURL resource:resource];
                
                [resources addObject:item];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
    return resources;
}

- (void) removeFeedItem:(FeedItem *) item {
    
    const char *dbpath = [[self dataBasePath] UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_open(dbpath, &rssDataBase) == SQLITE_OK)
    {
        NSString *quetyToRemove = [NSString stringWithFormat: @"DELETE FROM FeedItem WHERE FeedItem.id = \"%@\"", @(item.identifier)];
        
        const char *remove_stmt = [quetyToRemove UTF8String];
        
        sqlite3_prepare_v2(rssDataBase, remove_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"FeedItem removed");
        } else {
            NSLog(@"Failed to remove FeedItem");
        }
        sqlite3_finalize(statement);
        sqlite3_close(rssDataBase);
    }
    
}

#pragma mark - DateConverter

- (NSDate *) dateFromString:(NSString *) dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale preferredLanguages] objectAtIndex:0]]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    NSDate* date = [dateFormatter dateFromString:dateString];
    return date;
}

@end
