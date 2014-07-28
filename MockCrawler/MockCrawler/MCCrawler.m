//
//  MCCrawler.m
//  MockCrawler
//
//  Created by Mike Bernardo on 12/9/13.
//  Copyright (c) 2013 Mike Bernardo. All rights reserved.
//

#import "MCCrawler.h"

#import "MCCrawlSpec.h"
#import "MCUser.h"
#import "MCProject.h"
#import "MCProjectItem.h"

#import <AppKit/AppKit.h>

void myFSCallback(
ConstFSEventStreamRef streamRef,
void *clientCallBackInfo,
size_t numEvents,
void *eventPaths,
const FSEventStreamEventFlags eventFlags[],
const FSEventStreamEventId eventIds[]) {

    // something changed. Re-crawl!
    MCCrawler* crawler = (__bridge MCCrawler*)clientCallBackInfo;
    
    [crawler crawl];
    [crawler generateThumbnails];
    [crawler serialize];
//    int i;
//    char **paths = eventPaths;
//    
//    // printf("Callback called\n");
//    for (i=0; i<numEvents; i++) {
////        int count;
//        /* flags are unsigned long, IDs are uint64_t */
//        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
//    }
    
}


void myFSCallback2(
                  ConstFSEventStreamRef streamRef,
                  void *clientCallBackInfo,
                  size_t numEvents,
                  void *eventPaths,
                  const FSEventStreamEventFlags eventFlags[],
                  const FSEventStreamEventId eventIds[]) {
    
    
    int i;
    char **paths = eventPaths;
    
    // printf("Callback called\n");
    for (i=0; i<numEvents; i++) {
        //        int count;
        /* flags are unsigned long, IDs are uint64_t */
        printf("Change %llu in %s, flags %u\n", eventIds[i], paths[i], (unsigned int)eventFlags[i]);
    }
    
}


@interface MCCrawler ()
@property (nonatomic, strong) NSMutableArray* users;


@end

@implementation MCCrawler
-(id) init {
    if (self = [super init]) {
        self.users = [[NSMutableArray alloc] init];
        self.verboseOutput = NO;
        self.maxAge = 60*60*24*365; // 1 year old
    }
    
    return self;
}


-(void) startListeners {
    
    NSMutableArray* paths = [[NSMutableArray alloc] init];
    
    
    // listen to all seed directories
    for (MCUser* u in self.users) {
        for (MCCrawlSpec* spec in u.crawlSpecs) {
            [paths addObject:spec.seedPath];
            if (self.verboseOutput)
                NSLog(@"Starting listener for %@",spec.seedPath);
            
        }
    }
    
//
//    // listen to all project directories
//    for (MCUser* user in self.users) {
//        for (MCProject* project in user.projects) {
//            NSURL* path = project.path;
//            
//            [paths addObject:[path path]];
//            
//            if (self.verboseOutput)
//                NSLog(@"Starting listener for %@",[path path]);
//        }
//    }
    
    
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 3.0; // seconds
    
    FSEventStreamContext streamContext;
    streamContext.info = (__bridge void*)self;
    streamContext.retain = NULL;
    streamContext.release = NULL;
    streamContext.copyDescription = NULL;
    
    stream = FSEventStreamCreate(NULL,
                                 &myFSCallback,
                                 &streamContext,
                                 (__bridge CFArrayRef)paths,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagNone /* Flags explained in reference */
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream, [[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    
    NSLog(@"FS listeners started. Waiting.");
    
}

-(void) serialize {
    
    // build dictionary representation
    
//    NSDateFormatter* df = [[NSDateFormatter alloc] init];
//    [df setDateStyle:NSDateFormatterShortStyle];
//    [df setTimeStyle:NSDateFormatterShortStyle];
    
    NSMutableArray* outputList =[[NSMutableArray alloc] init];
    
    for (MCUser* user in self.users) {
        
        NSMutableDictionary* userDict = [[NSMutableDictionary alloc] init];
        NSMutableArray* projectList = [[NSMutableArray alloc] init];
        
        userDict[@"name"] = user.name;
        userDict[@"projects"] = projectList;
        
        [outputList addObject:userDict];
        
        for (MCProject* project in user.projects) {
            
            NSMutableDictionary* projectDict = [[NSMutableDictionary alloc] init];
            NSMutableArray* itemList = [[NSMutableArray alloc] init];
            
            projectDict[@"name"] = project.name;
            projectDict[@"items"] = itemList;
            
            [projectList addObject:projectDict];
            
            for (MCProjectItem* item in project.items) {
                
                NSMutableDictionary* itemDict = [[NSMutableDictionary alloc] init];
                itemDict[@"name"] = item.name;
                itemDict[@"path"] = [[item.path path] stringByReplacingOccurrencesOfString:self.crawlRoot withString:@""];
                itemDict[@"lastModified"] = [NSString stringWithFormat:@"%.0f", [item.lastModified timeIntervalSince1970]];
                
                [itemList addObject:itemDict];
            }
        }
    }
    
    if (![NSJSONSerialization isValidJSONObject:outputList]) {
        NSLog(@"Could not serialize user list. (invalid json object)");
        return;
    }
    
    NSError* error;
    NSData* outputData = [NSJSONSerialization dataWithJSONObject:outputList options:NSJSONWritingPrettyPrinted error:&error];

    if (!outputData || error) {
        NSLog(@"Could not serialize user list. %@",error);
        return;
    }
    
    [outputData writeToFile:self.outputPath atomically:YES];
    
    NSLog(@"Output serialized to %@",self.outputPath);
}

-(void) generateThumbnails {
    
    NSMutableDictionary* imageOptions = [[NSMutableDictionary alloc] init];
    imageOptions[(NSString*)kCGImageSourceCreateThumbnailFromImageIfAbsent] = @YES;
    imageOptions[(NSString*)kCGImageSourceThumbnailMaxPixelSize] = @200;
    
    
    for (MCUser* user in self.users) {
        
        for (MCProject* project in user.projects) {
            
            for (MCProjectItem* item in project.items) {
                
                // TODO: collisions possible!
                NSString* cacheParent = [self.cachePath stringByAppendingFormat:@"/%@/%@",user.name,project.name];
                NSString* cachePath = [cacheParent stringByAppendingFormat:@"/%@",item.name];
                
                
                // TODO: check timestamp of existing thumbnail in case original was updated
                if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
                    continue;
                
                
                CGImageSourceRef itemRef = CGImageSourceCreateWithURL((__bridge CFURLRef)item.path, NULL);
                

                CGImageRef thumbnailRef = CGImageSourceCreateThumbnailAtIndex (itemRef, 0, (__bridge CFDictionaryRef)imageOptions );
                
                if (!itemRef || !thumbnailRef) {
                
                    CFRelease(itemRef);
                    CFRelease(thumbnailRef);
                    continue;
                }
                
                [[NSFileManager defaultManager] createDirectoryAtPath:cacheParent withIntermediateDirectories:YES attributes:nil error:nil];
                
                // TODO: use correct filename extension in case source is not a PNG
                NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:thumbnailRef];
                NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
                [pngData writeToFile:cachePath atomically:YES];
                
                if (self.verboseOutput)
                    NSLog(@"Generating thumbnail: %@",cachePath);
                
                CFRelease(itemRef);
                CFRelease(thumbnailRef);
                
            }
        }
    }
}

-(void)crawlProject:(MCProject*)project withSpec:(MCCrawlSpec*)spec {
    
    NSArray *keys = @[NSURLIsDirectoryKey, NSURLLocalizedNameKey, NSURLPathKey, NSURLContentModificationDateKey ];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:project.path
                                                             includingPropertiesForKeys:keys
                                                                                options:(NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles)
                                                                         errorHandler:^(NSURL *url, NSError *error) {
                                                                             return YES;
                                                                         }];
    
    
    NSDate* maxAgeDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxAge];
    
    for (NSURL *url in enumerator) {
        
        // skip directories
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        if ([isDirectory boolValue]) continue;
        
        NSString* path = nil;
        NSString *localizedName = nil;
        NSDate* lastModified = nil;

        [url getResourceValue:&path forKey:NSURLPathKey error:NULL];
        [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
        [url getResourceValue:&lastModified forKey:NSURLContentModificationDateKey error:NULL];
        
        // skip files that are too old
        if ([maxAgeDate compare:lastModified] != NSOrderedAscending) continue;
        
        // match item regexes
        for (NSRegularExpression* regex in spec.itemMatchers) {
            if ([regex numberOfMatchesInString:path options:0 range:NSMakeRange(0,[path length])]) {
                
                MCProjectItem* item = [[MCProjectItem alloc] init];
                item.name = localizedName;
                item.path = [NSURL fileURLWithPath:path];
                item.lastModified = lastModified;
                
                if (self.verboseOutput)
                    NSLog(@"    ->: %@",item.name);
                [project.items addObject:item];
                
                break;
            }
        }
    }

}

-(void)crawlSpec:(MCCrawlSpec*)spec forUser:(MCUser*)user {
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // get all top-level items in the seed path
    NSURL* seedContainer = [NSURL fileURLWithPath:spec.seedPath];
    NSArray* targetDirContents = [fm contentsOfDirectoryAtURL:seedContainer
                                   includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey, NSURLPathKey]
                                                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
                                                        error:&error];
    
    
    NSString* name;
    NSNumber* isDirectory;
    NSString* path;
    
    // test each top-level directory for matches in the crawl spec's project-matching regexes
    for (NSURL* item in targetDirContents) {
        
        [item getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
        [item getResourceValue:&name forKey:NSURLNameKey error:&error];
        [item getResourceValue:&path forKey:NSURLPathKey error:&error];

        if ([isDirectory boolValue]) {
            
            for (NSRegularExpression* regex in spec.projectMatchers) {
                NSUInteger numMatches = [regex numberOfMatchesInString:name options:0 range:NSMakeRange(0,[name length])];
                if (numMatches > 0) {
                    MCProject* project = [[MCProject alloc] init];
                    project.name = name;
                    project.path = [NSURL fileURLWithPath:[item path]];
                    
                    if (self.verboseOutput)
                        NSLog(@"Project: %@",project.name);
                    [self crawlProject:project withSpec:spec];
                    
                    if (project.items.count > 0)
                        [user.projects addObject:project];

                    break;
                }
            }
        }
    }
    
}

-(void)crawl {
    
    NSError *error = nil;

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Crawl started");
    [self.users removeAllObjects];
    
    // parse crawl configuration
    NSArray* userlist = [NSArray arrayWithContentsOfFile:self.configPath];
    if (!userlist || [userlist count] < 1) {
        NSLog(@"No configuration found at %@",self.configPath);
        return;
    }
    for (NSDictionary* userDict in userlist) {
        MCUser* u = [[MCUser alloc] init];

        u.name = userDict[@"user"];
        
        for (NSDictionary* specDict in userDict[@"crawlSpecs"]) {
            MCCrawlSpec* spec = [[MCCrawlSpec alloc] init];
            
            spec.seedPath =  [NSString stringWithFormat:@"%@/%@", self.crawlRoot, specDict[@"seed"]];
            
            for (NSString* regexString in specDict[@"projectMatchers"]) {
                
                error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                
                if (!regex || error) {
                    NSLog(@"Could not compile project matcher regex (%@) for user %@:\n%@",regexString,u.name,error);
                }
                [spec.projectMatchers addObject:regex];
            }
            
            for (NSString* regexString in specDict[@"itemMatchers"]) {
                error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                
                if (!regex || error) {
                    NSLog(@"Could not compile item matcher regex (%@) for user %@:\n%@",regexString,u.name,error);
                }
                [spec.itemMatchers addObject:regex];
            }
            

            [u.crawlSpecs addObject:spec];
        }
        
        [self.users addObject:u];
    }
    
    // execute all crawls
    for (MCUser* u in self.users) {
        for (MCCrawlSpec* spec in u.crawlSpecs) {
            [self crawlSpec:spec forUser:u];
        }
    }
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Crawl ended (%f seconds)",endTime-startTime);
    

}


@end
