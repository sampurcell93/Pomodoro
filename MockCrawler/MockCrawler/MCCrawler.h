//
//  MCCrawler.h
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCrawler : NSObject

@property (nonatomic, assign) BOOL verboseOutput;
@property (nonatomic, strong) NSString* crawlRoot;
@property (nonatomic, strong) NSString* configPath;
@property (nonatomic, strong) NSString* outputPath;
@property (nonatomic, strong) NSString* cachePath;
@property (nonatomic, assign) NSTimeInterval maxAge;

-(void) crawl;
-(void) generateThumbnails;
-(void) serialize;
-(void) startListeners;
@end
