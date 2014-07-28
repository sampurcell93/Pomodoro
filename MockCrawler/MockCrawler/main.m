//
//  main.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCCrawler.h"

int main(int argc, const char * argv[])
{


    
    @autoreleasepool {
        
        NSDictionary* daemonConfig = [NSDictionary dictionaryWithContentsOfFile:@"crawlDaemonConfig.plist"];
        
        if (!daemonConfig) {
            NSLog(@"No crawlDaemonConfig.plist found.");
            exit(EXIT_FAILURE);
        }
        MCCrawler* c = [[MCCrawler alloc] init];        
        c.crawlRoot = [daemonConfig objectForKey:@"crawlRoot"];
        c.configPath = @"crawlConfig.plist";
        c.outputPath = [daemonConfig objectForKey:@"outputPath"];
        c.cachePath = [daemonConfig objectForKey:@"cachePath"];
        c.verboseOutput = YES;
        [c crawl];
        [c generateThumbnails];
        [c serialize];
        [c startListeners];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
    return 0;
}

