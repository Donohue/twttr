//
//  TweetTableViewCell.h
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import <UIKit/UIKit.h>

@interface TweetTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextView *tweetLabel;
@property (nonatomic, copy) void(^linkBlock)(NSURL*);

+ (CGFloat)heightForWidth:(CGFloat)width andTweet:(NSString *)tweet;
- (void)setDisplayName:(NSString *)displayName andUsername:(NSString *)username;

@end
