//
//  MCProject.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import "MCProject.h"

@interface MCProject ()

@property (nonatomic, strong) NSMutableArray* items;
    
@end
    
@implementation MCProject

@synthesize items = _items;

-(id) init {
    if (self = [super init]) {
        
        self.items = [[NSMutableArray alloc] init];
    }
    
    return self;
}


@end
