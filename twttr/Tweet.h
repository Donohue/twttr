//
//  Tweet.h
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *displayname;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSURL *avatar_url;
@property (nonatomic, strong) NSDate *created;

- (id)initWithDict:(NSDictionary *)dict;

@end
