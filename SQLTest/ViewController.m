//
//  ViewController.m
//  SQLTest
//
//  Created by Dzmitry Noska on 9/10/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "ViewController.h"
#import "SQLLiteManager.h"

@interface ViewController ()
@end

@implementation ViewController

#pragma mark - CREATE DB

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[SQLLiteManager sharedSQLLiteManager] createDB];
    
    
    FeedResource* resource2 = [[FeedResource alloc] initWithName:@"tytby" url:[NSURL URLWithString:@"https://news.tut.by/rss/index.rss"]];
    resource2.identifier = 2;
//
    [[SQLLiteManager sharedSQLLiteManager] addFeedResource:resource2];
//
//    FeedResource* resource2 = [[FeedResource alloc] initWithName:@"apple" url:[NSURL URLWithString:@"https://developer.apple.com/news"]];
//    resource2.identifier = 2;
//    [[SQLLiteManager sharedSQLLiteManager] addFeedResource:resource2];
//
//    [[SQLLiteManager sharedSQLLiteManager] removeFeedResource:resource2];
    
    NSLog(@"%@", [[SQLLiteManager sharedSQLLiteManager] feedResources]);
    
    FeedItem* item2 = [[FeedItem alloc] init];
    item2.itemTitle = @"title";
    item2.link = [[NSMutableString alloc] initWithString:@"link"];
    item2.pubDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    item2.itemDescription = [[NSMutableString alloc] initWithString:@"description"];
    item2.enclosure = @"enclosure";
    item2.imageURL = @"imageURL";
    item2.isFavorite = NO;
    item2.isReaded = NO;
    item2.isAvailable = NO;
    item2.resourceURL = [NSURL URLWithString:@"urlString"];
    item2.resource = resource2;
//
    FeedItem* newFI2 = [[SQLLiteManager sharedSQLLiteManager] addFeedItem:item2];
    NSLog(@"sd");
//    NSMutableArray<FeedItem *>* items = [[SQLLiteManager sharedSQLLiteManager] feedItems];
//
//    NSLog(@"%@", items);
//
//    FeedItem* item = [items firstObject];
//    item.isReaded = YES;
//
//    [[SQLLiteManager sharedSQLLiteManager] updateFeedItem:item];
//
//    NSMutableArray<FeedItem *>* items2 = [[SQLLiteManager sharedSQLLiteManager] feedItems];
//
//    NSLog(@"%@", items2);
}

@end
