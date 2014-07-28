//
//  MCProjectItem.h
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCProjectItem : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSURL* path;
@property (nonatomic, strong) NSDate* lastModified;

@end
