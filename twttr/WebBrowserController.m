//
//  WebBrowserController.m
//  Instapaper
//
//  Created by Marco Arment on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WebBrowserController.h"
#import "UIImage+ImageUtils.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define	kAnimationIDBrowserLoading @"IPBrowserLoadingAnimation"
#define kBarHeight 44.0
#define kButtonWidth 110
#define kButtonHeight 25
#define kLabelFontSize 17.0
#define kReadLaterFont [UIFont fontWithName:@"HelveticaNeue" size:kLabelFontSize]

@implementation WebBrowserController
@synthesize webView;
@synthesize urlBar;
@synthesize backButton;
@synthesize readLaterButton;
@synthesize loadingIndicator;
@synthesize url;
@synthesize notificationLabel;
@synthesize inlineMode;
@synthesize closeBlock;
@synthesize shouldAnimateReadLaterSaves;
@synthesize closeButton;
@synthesize forwardButton;
@synthesize actionButton;
@synthesize toolBar;
@synthesize ipadToolBar;
@synthesize navigationBar;

- (id)initWithURL:(NSURL *)theURL {
    if ( (self = [super initWithNibName:@"WebBrowserController" bundle:[NSBundle mainBundle]]) ) {
		self.url = theURL;
		loading = NO;
        inlineMode = NO;
        closeBlock = nil;
        shouldAnimateReadLaterSaves = NO;
    }
    return self;
}

- (void)setupBrowserButtonItems {
    UIColor *deactiveColor = [UIColor colorWithWhite:230.0/255 alpha:1.0];
    UIColor *activeColor = [UIColor darkGrayColor];
    
    UIButton *leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    leftArrow.frame = CGRectMake(0, 0, 25, 25);
    [leftArrow setImage:[UIImage maskedImageNamed:@"left_chevron.png"
                                              color:activeColor]
               forState:UIControlStateNormal];
    [leftArrow setImage:[UIImage maskedImageNamed:@"left_chevron.png"
                                              color:deactiveColor]
               forState:UIControlStateDisabled];
    [leftArrow addTarget:self
                  action:@selector(backButtonClicked:)
        forControlEvents:UIControlEventTouchUpInside];
    [backButton setCustomView:leftArrow];
    
    UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    rightArrow.frame = CGRectMake(0, 0, 25, 25);
    [rightArrow setImage:[UIImage maskedImageNamed:@"right_chevron.png"
                                               color:activeColor]
                forState:UIControlStateNormal];
    [rightArrow setImage:[UIImage maskedImageNamed:@"right_chevron.png"
                                               color:deactiveColor]
                forState:UIControlStateDisabled];
    [rightArrow addTarget:self
                   action:@selector(forwardButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    [forwardButton setCustomView:rightArrow];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0, 0, 40, 40);
    [moreButton setImage:[UIImage maskedImageNamed:@"icon-arrow.png"
                                               color:activeColor]
                forState:UIControlStateNormal];
    [moreButton setImage:[UIImage maskedImageNamed:@"icon-arrow.png"
                                               color:deactiveColor]
                forState:UIControlStateDisabled];
    [moreButton addTarget:self
                   action:@selector(actionsButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [actionButton setCustomView:moreButton];
    
    NSString *buttonTitle = NSLocalizedString(@"Save", nil);
    CGSize size = [buttonTitle sizeWithAttributes:@{NSFontAttributeName: kReadLaterFont}];
    UIButton *readLaterView = [UIButton buttonWithType:UIButtonTypeCustom];
    readLaterView.frame = CGRectMake(0, 0, size.width, size.height);
    [readLaterView setTitle:buttonTitle forState:UIControlStateNormal];
    [readLaterView setTitleColor:activeColor forState:UIControlStateNormal];
    [readLaterView setTitleColor:deactiveColor forState:UIControlStateDisabled];
    readLaterView.titleLabel.font = kReadLaterFont;
    readLaterView.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [readLaterView addTarget:self
                      action:@selector(readLaterButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    [readLaterView.titleLabel sizeToFit];
    readLaterView.frame = readLaterView.titleLabel.bounds;
    
    [readLaterButton setCustomView:readLaterView];
}

- (void)readLaterButtonClicked:(id)sender {
    NSLog(@"Read Later");
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [webView setOpaque:NO];
    
	[loadingIndicator.superview sendSubviewToBack:loadingIndicator];
    
    statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0)];
    statusBarBg.backgroundColor = [UIColor whiteColor];
    statusBarBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:statusBarBg];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 loadingIndicator.frame.size.width + 5,
                                                                 loadingIndicator.frame.size.height)];
    [rightView addSubview:loadingIndicator];
    urlBar.rightView = rightView;
    urlBar.rightViewMode = UITextFieldViewModeUnlessEditing;
    urlBar.placeholder = NSLocalizedString(@"Address or search terms", nil);
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, urlBar.frame.size.height)];
    urlBar.leftView = paddingView;
    urlBar.leftViewMode = UITextFieldViewModeAlways;
    urlBar.layer.cornerRadius = 5.0;
    urlBar.layer.masksToBounds = YES;
    urlBar.borderStyle = UITextBorderStyleNone;
    
    closeButton.title = NSLocalizedString(@"Close", nil);
    navigationBar.translucent = NO;
    navigationBar.barTintColor = [UIColor whiteColor];
    toolBar.barTintColor = [UIColor whiteColor];
    
    [self setupBrowserButtonItems];
    actionButton.accessibilityLabel = NSLocalizedString(@"Options", nil);
    readLaterButton.accessibilityLabel = NSLocalizedString(@"Save", nil);
    backButton.accessibilityLabel = NSLocalizedString(@"Navigate Back", nil);
    forwardButton.accessibilityLabel = NSLocalizedString(@"Navigate Forward", nil);
    readLaterButton.enabled = NO;
	
	if (url) {
		[self browseToURL:url];
	}
    
    backButton.enabled = [webView canGoBack];
    forwardButton.enabled = [webView canGoForward];
    actionButton.enabled = YES;
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (IBAction)actionsButtonTapped:(UIButton *)sender
{
    if (!self.url)
        return;
    
    NSMutableArray *items = [NSMutableArray arrayWithObject:self.url];
    if (title) {
        [items addObject:title];
    }
    
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                      applicationActivities:@[]];
    activityController.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                                 UIActivityTypeAirDrop,
                                                 @"com.marcoarment.instapaperpro.InstapaperSave"];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	urlBar.textColor = [UIColor blackColor];
	urlBar.text = [self.url absoluteString];
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.urlBar resignFirstResponder];
    [self.webView resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
	NSString *u = tf.text;
    if ([u length] == 0) {
        return NO;
    }
	else if ([u rangeOfString:@" "].location != NSNotFound || ([u rangeOfString:@"."].location == NSNotFound && [u rangeOfString:@"/"].location == NSNotFound)) {
		// Search
		u = [NSString stringWithFormat:@"http://www.google.com/m/search?ie=UTF-8&oe=UTF-8&q=%@", u];
	} else {
		if ([u rangeOfString:@":"].location == NSNotFound) u = [NSString stringWithFormat:@"http://%@", u];
	}

	[tf resignFirstResponder];
	
	[self browseToURL:[NSURL URLWithString:u]];
    
    self.inlineMode = NO;
	return YES;
}

- (void)stoppedLoading:(BOOL)wasSuccessful
{
	loading = NO;
	[loadingIndicator stopAnimating];
	[loadingIndicator.superview sendSubviewToBack:loadingIndicator];
    forwardButton.enabled = [webView canGoForward];
    backButton.enabled = [webView canGoBack];
	
	// Things that can't be Read Latered:
	if (wasSuccessful) readLaterButton.enabled = ! (
			! url || // Invalid URLs
			([[url path] isEqualToString:@"/"] && [[url absoluteString] rangeOfString:@"?"].location == NSNotFound) ||    // Roots of domains
			[[url scheme] rangeOfString:@"http"].location == NSNotFound  || // Non-HTTP/HTTPS protocols
			[[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML.length;"] intValue] < 500 // Less than 500 bytes of HTML, or non-HTML content (like a PDF)
	);    
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
	NSLog(@"Error code %d", (int)[error code]);
	
	if ([error code] == -999) {
        [self setDisplayedURL:wv.request.URL];
        return; // Operation could not be completed
    }
	
	[self stoppedLoading:NO];

	if ([error code] == -1009) {
#if 0
        [IPAlertView showAlertWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                                message:NSLocalizedString(@"Sorry, you must be online to view this page.", nil)];
#endif
	} else {
		[self showNotification:NSLocalizedString(@"Error loading page.", nil)];
	}	
}

- (BOOL)shouldProcessRedirectsForURL:(NSURL *)u
{
    return YES;
}

- (BOOL)isAppStoreURL:(NSURL *)u {
    return ([[u scheme] isEqualToString:@"http"] || [[u scheme] isEqualToString:@"https"]) &&
            ([[u host] rangeOfString:@"phobos.apple."].location != NSNotFound ||
            [[u host] rangeOfString:@"itunes.apple."].location != NSNotFound);
}

- (BOOL)systemShouldOpenURL:(NSURL *)u
{
    return
        ! ([[u scheme] isEqualToString:@"http"] || [[u scheme] isEqualToString:@"https"] || [[u scheme] isEqualToString:@"about"]) ||
        [[u host] rangeOfString:@"maps.google."].location != NSNotFound ||
        [[u host] rangeOfString:@"phobos.apple."].location != NSNotFound ||
        [[u host] rangeOfString:@"itunes.apple."].location != NSNotFound
    ;
}

- (void)browseToURL:(NSURL *)newUrl
{
	[self browsingToURL:newUrl];
    
    if ([self isAppStoreURL:newUrl]) {
#if 0
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App Store Page", @"View app webpage in App Store")
                                                        message:NSLocalizedString(@"Instapaper cannot display App Store pages. Would you like to open this page in the App Store?", nil)] autorelease];
        [alert addButtonWithTitle:NSLocalizedString(@"No", nil) action:^{
            [self closeButtonClicked:nil];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil) action:^{
            [[UIApplication sharedApplication] openURL:newUrl];
            [self closeButtonClicked:nil];
        }];
        [alert show];
#endif
    }
    else if ([self systemShouldOpenURL:newUrl]) {
        [[UIApplication sharedApplication] openURL:newUrl];
        [self webViewDidFinishLoad:webView];
    } else {
        [webView loadRequest:[NSURLRequest requestWithURL:newUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30]];
    }
	[webView becomeFirstResponder];
}

- (void)setDisplayedURL:(NSURL *)newUrl
{
	NSString *urlStr = [newUrl absoluteString];
	
    if ([urlStr rangeOfString:@"applewebdata:"].location == NSNotFound && [urlStr rangeOfString:@"about:"].location == NSNotFound) {
		urlBar.text = urlStr;
		urlBar.textColor = [UIColor blackColor];
	}
	self.url = newUrl;
    self.actionButton.enabled = self.url != nil;
}

- (void)browsingToURL:(NSURL *)newUrl
{
	if (newUrl && [[self.url absoluteString] isEqualToString:[newUrl absoluteString]]) {
		return;
	}
    
	if (loading) return;
	loading = YES;
    title = nil;
    
	[self setDisplayedURL:newUrl];
	[loadingIndicator.superview bringSubviewToFront:loadingIndicator];
	[loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    title = [wv stringByEvaluatingJavaScriptFromString:@"document.title;"];
	[self setDisplayedURL:[NSURL URLWithString:wv.request.URL.absoluteString]];
	[self stoppedLoading:YES];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#if 0
	// Block Instapaper's "Read Later" hello2 embeds
	if ([[[request URL] host] ipEndsWith:@"instapaper.com"] && [[[request URL] path] isEqualToString:@"/e2"]) return NO;

    // Block Readability embeds
    if ([[[request URL] absoluteString] ipContains:@"://readability.com/static/embed"]) return NO;
    
    // Block RIL embeds
    if ([[[request URL] absoluteString] ipContains:@"://readitlaterlist.com/"] || 
        [[[request URL] absoluteString] ipContains:@"://readitlater.com/"]
    ) return NO;
#endif
    
    if (navigationType == UIWebViewNavigationTypeOther) return YES;

    if ([self isAppStoreURL:request.URL]) {
#if 0
        IPAlertView *alert = [[[IPAlertView alloc] initWithTitle:NSLocalizedString(@"App Store Page", @"View app webpage in App Store")
                                                         message:NSLocalizedString(@"Instapaper cannot display App Store pages. Would you like to open this page in the App Store?", nil)] autorelease];
        [alert addButtonWithTitle:NSLocalizedString(@"No", nil) action:^{
            [self closeButtonClicked:nil];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"Yes", nil) action:^{
            [[UIApplication sharedApplication] openURL:request.URL];
            [self closeButtonClicked:nil];
        }];
        [alert show];
#endif
        return NO;
    }
    else if ([self systemShouldOpenURL:[request URL]]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        [self webViewDidFinishLoad:wv];
        return NO;
    }
	
	[self browsingToURL:([request mainDocumentURL] ? [request mainDocumentURL] : [request URL])];
	return YES;
}

- (IBAction)closeButtonClicked:(id)sender
{
	[webView stopLoading];
    if (closeBlock) closeBlock(NO);
    else [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)forwardButtonClicked:(id)sender {
    if ([webView canGoForward]) {
        [webView goForward];
    }
}

- (IBAction)backButtonClicked:(id)sender
{
	if ([webView canGoBack]) {
        [webView stopLoading];
        [webView goBack];
        forwardButton.enabled = YES;
    }
    
    backButton.enabled = [webView canGoBack];
}

- (void)showNotification:(NSString *)notificationStr
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNotification:) object:nil];

	notificationLabel.layer.cornerRadius = 20.0f;
	notificationLabel.text = notificationStr;
	[notificationLabel setAlpha:0.85f];
	[notificationLabel.superview bringSubviewToFront:notificationLabel];
	[self performSelector:@selector(hideNotification:) withObject:nil afterDelay:0.66];
}

- (void)hideNotification:(id)sender
{
	[UIView beginAnimations:NULL context:NULL];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[notificationLabel setAlpha:0.0f];
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[notificationLabel.superview sendSubviewToBack:notificationLabel];
}

@end
