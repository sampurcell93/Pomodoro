//
//  MCUser.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import "MCUser.h"

@interface MCUser ()
@property (nonatomic, strong) NSMutableArray* crawlSpecs;
@property (nonatomic, strong) NSMutableArray* projects;
@end

@implementation MCUser

-(id)init {
    if (self = [super init]) {
        self.crawlSpecs = [[NSMutableArray alloc] init];
        self.projects = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
