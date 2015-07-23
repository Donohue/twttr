//
//  ViewController.m
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import "ViewController.h"
#import "WebBrowserController.h"
#import "TweetTableViewCell.h"
#import "Tweet.h"
#import "UIImageView+AFNetworking.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ViewController ()

@property (nonatomic, strong) NSArray *tweets;

@end

@implementation ViewController

#define kReuseIdentifier @"cell"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CredentialManager sharedInstance].delegate = self;
    [[CredentialManager sharedInstance] authorize];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.scrollsToTop = YES;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithWhite:220.0/255 alpha:1];
    [self.tableView registerClass:[TweetTableViewCell class] forCellReuseIdentifier:kReuseIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"twttr"]];
}

-(void)showRateLimitingError {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rate Limit Error", nil)
                                                                             message:NSLocalizedString(@"Please try again!", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){}];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

-(CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    return [TweetTableViewCell heightForWidth:tableView.frame.size.width andTweet:tweet.text];
}

-(NSInteger)tableView:(nonnull UITableView *)tableView indentationLevelForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 0;
}

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    TweetTableViewCell *cell = (TweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    cell.tweetLabel.text = tweet.text;
    [cell.avatar setImageWithURL:tweet.avatar_url];
    [cell setDisplayName:tweet.displayname andUsername:tweet.username];
    
    cell.linkBlock = ^(NSURL *url) {
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        safariViewController.delegate = self;
        [self presentViewController:safariViewController animated:YES completion:nil];
    };
    
    return cell;
}

-(void)safariViewControllerDidFinish:(nonnull SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark CredentialManagerDelegate
- (void)credentialManagerSucceeded:(BOOL)success {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Authorization Failed", nil)
                                                                             message:NSLocalizedString(@"Please try again!", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){}];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)credentialManagerNoAccounts {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Twitter Account", nil)
                                                                             message:NSLocalizedString(@"Please try again!", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){}];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:NULL];
}

- (void)credentialManagerAuthorizedAccounts:(NSArray *)accounts {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:requestURL
                                               parameters:@{}];
    request.account = accounts[0];
    
    __weak typeof(self) weakSelf = self;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        id result = [NSJSONSerialization JSONObjectWithData:responseData
                                                    options:0
                                                      error:&error];
        if ([result isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showRateLimitingError];
            });
            return;
        }
        
        NSArray *tweetArray = (NSArray *)result;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:[tweetArray count]];
        for (NSDictionary *tweetDict in tweetArray) {
            Tweet *tweet = [[Tweet alloc] initWithDict:tweetDict];
            [arr addObject:tweet];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tweets = arr;
            [weakSelf.tableView reloadData];
        });
    }];
}


@end
