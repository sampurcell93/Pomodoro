//
//  MCCrawlSpec.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import "MCCrawlSpec.h"

@interface MCCrawlSpec ()
@property (nonatomic, strong) NSMutableArray* projectMatchers;
@property (nonatomic, strong) NSMutableArray* itemMatchers;

@end

@implementation MCCrawlSpec

-(id) init {
    if (self = [super init]) {
        
        self.projectMatchers = [[NSMutableArray alloc] init];
        self.itemMatchers = [[NSMutableArray alloc] init];
    }
    
    return self;
}
@end
