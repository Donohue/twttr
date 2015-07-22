//
//  ViewController.h
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "CredentialManager.h"

@interface ViewController : UITableViewController <CredentailManagerDelegate, SFSafariViewControllerDelegate>


@end

