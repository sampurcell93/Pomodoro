//
//  MCUser.h
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCUser : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, readonly) NSMutableArray* crawlSpecs;
@property (nonatomic, readonly) NSMutableArray* projects;



@end
