//
//  TweetTableViewCell.m
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import "TweetTableViewCell.h"

@implementation TweetTableViewCell

#define kLeftPadding 12
#define kAvatarTopPadding 21
#define kTextTopPadding 17
#define kAvatarRightPadding 12
#define kAvatarSize 30
#define kTextLeftPadding (kLeftPadding + kAvatarRightPadding + kAvatarSize)
#define kUsernameFontSize 16.0f
#define kTweetFontSize 16.0f

+ (CGFloat)heightForWidth:(CGFloat)width andTweet:(NSString *)tweet {
    CGSize size = [tweet boundingRectWithSize:CGSizeMake(width - kTextLeftPadding, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kTweetFontSize]}
                                                context:NULL].size;
    return ceilf(size.height) + kTextTopPadding * 2 + kUsernameFontSize + 12.0f;
}

- (void)setDisplayName:(NSString *)displayName andUsername:(NSString *)username {
    NSString *text = [NSString stringWithFormat:@"%@ @%@", displayName, username];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kUsernameFontSize]}];
    [attrStr setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kUsernameFontSize]} range:NSMakeRange(0, [displayName length])];
    self.usernameLabel.attributedText = attrStr;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftPadding, kAvatarTopPadding, kAvatarSize, kAvatarSize)];
        self.avatar.layer.cornerRadius = 3.0f;
        self.avatar.clipsToBounds = YES;
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTextLeftPadding, kTextTopPadding,
                                                                       self.contentView.frame.size.width - kTextLeftPadding,
                                                                       kUsernameFontSize + 4.0f)];
        self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.usernameLabel.numberOfLines = 1;
        self.usernameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.usernameLabel.font = [UIFont systemFontOfSize:kUsernameFontSize];
        
        self.tweetLabel = [[UITextView alloc] initWithFrame:CGRectMake(kTextLeftPadding, kTextTopPadding + kUsernameFontSize + 8,
                                                                    self.contentView.frame.size.width - kTextLeftPadding,
                                                                    kTweetFontSize + 4.0f)];
        self.tweetLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tweetLabel.font = [UIFont systemFontOfSize:kTweetFontSize];
        self.tweetLabel.textContainerInset = UIEdgeInsetsZero;
        self.tweetLabel.contentInset = UIEdgeInsetsMake(0, -4, 0, 0);
        self.tweetLabel.dataDetectorTypes = UIDataDetectorTypeLink;
        self.tweetLabel.editable = NO;
        self.tweetLabel.delegate = self;
        
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.tweetLabel];
        [self.contentView addSubview:self.usernameLabel];
    }
    return self;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(nonnull UITextView *)textView shouldInteractWithURL:(nonnull NSURL *)URL inRange:(NSRange)characterRange {
    if (self.linkBlock) {
        self.linkBlock(URL);
        return NO;
    }
    return YES;
}

@end
