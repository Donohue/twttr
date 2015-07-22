//
//  Tweet.m
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import "Tweet.h"

@implementation Tweet

+(NSDate *)dateFromCreatedAt:(NSString *)createdAt {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    return [df dateFromString:createdAt];
}

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.identifier = dict[@"id_str"];
        self.text = dict[@"text"];
        self.username = dict[@"user"][@"screen_name"];
        self.displayname = dict[@"user"][@"name"];
        self.avatar_url = [NSURL URLWithString:dict[@"user"][@"profile_image_url"]];
        self.created = [Tweet dateFromCreatedAt:dict[@"created_at"]];
    }
    return self;
}

@end
