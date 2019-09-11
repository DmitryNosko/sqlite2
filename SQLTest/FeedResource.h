//
//  FeedResource.h
//  SQLTest
//
//  Created by Dzmitry Noska on 9/11/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedResource : NSObject
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSURL* url;
- (instancetype)initWithName:(NSString*) name url:(NSURL*) url;
- (instancetype)initWithID:(NSInteger) identifier name:(NSString*) name url:(NSURL*) url;
@end
