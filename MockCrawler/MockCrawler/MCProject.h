//
//  MCProject.h
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCProjectItem;

@interface MCProject : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSURL* path;
@property (nonatomic, readonly) NSMutableArray* items;

@end
