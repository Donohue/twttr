//
//  WebBrowserController.h
//  Instapaper
//
//  Created by Marco Arment on 2/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^WebBrowserControllerAction)(BOOL saved);

@interface WebBrowserController : UIViewController <UIWebViewDelegate, UITextFieldDelegate, UIActionSheetDelegate> {
	IBOutlet	UIWebView		*webView;
	IBOutlet	UITextField		*urlBar;
	IBOutlet	UIBarButtonItem *backButton;
    IBOutlet    UIBarButtonItem *forwardButton;
	IBOutlet	UIBarButtonItem *readLaterButton;
	IBOutlet	UIActivityIndicatorView	*loadingIndicator;

	IBOutlet	UINavigationItem *ipadNavigationItem;
	IBOutlet	UILabel *notificationLabel;
    IBOutlet    UIBarButtonItem *closeButton;
    IBOutlet    UIBarButtonItem *actionButton;
    IBOutlet    UIToolbar *toolBar;
    
    IBOutlet    UINavigationBar *ipadToolBar;
    IBOutlet    UINavigationBar *navigationBar;
    
    UIToolbar *ipadRightToolbar;
    UIView *statusBarBg;
	
	NSURL	*url;
	BOOL	loading;
    BOOL    inlineMode;
    WebBrowserControllerAction closeBlock;
    NSString *title;
}

- (id)initWithURL:(NSURL *)url;
- (void)browseToURL:(NSURL *)url;
- (void)browsingToURL:(NSURL *)url;

- (void)showNotification:(NSString *)notificationStr;

- (IBAction)actionsButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)readLaterButtonClicked:(id)sender;
- (IBAction)forwardButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet	UIWebView		*webView;
@property (nonatomic, retain) IBOutlet	UITextField		*urlBar;
@property (nonatomic, retain) IBOutlet	UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet	UIBarButtonItem *readLaterButton;
@property (nonatomic, retain) IBOutlet	UIActivityIndicatorView	*loadingIndicator;
@property (nonatomic, retain) IBOutlet  UILabel *notificationLabel;
@property (nonatomic, retain) IBOutlet  UIBarButtonItem *closeButton;
@property (nonatomic, retain) IBOutlet  UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet  UIBarButtonItem *actionButton;
@property (nonatomic, retain) IBOutlet  UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet  UINavigationBar *ipadToolBar;
@property (nonatomic, retain) IBOutlet  UINavigationBar *navigationBar;

@property (nonatomic, retain) NSURL	*url;

@property (nonatomic, assign) BOOL inlineMode;
@property (nonatomic, assign) BOOL showsCloseButton;
@property (nonatomic, assign) BOOL shouldAnimateReadLaterSaves;
@property (nonatomic, copy) WebBrowserControllerAction closeBlock;

@end
