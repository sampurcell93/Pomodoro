//
//  MCCrawlSpec.h
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCrawlSpec : NSObject

@property (nonatomic, strong) NSString* seedPath;
@property (nonatomic, readonly) NSMutableArray* projectMatchers;
@property (nonatomic, readonly) NSMutableArray* itemMatchers;

@end
