//
//  CredentialManager.m
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import "CredentialManager.h"
#import <Accounts/Accounts.h>

@implementation CredentialManager

+ (CredentialManager *)sharedInstance {
    static dispatch_once_t once;
    static CredentialManager *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[CredentialManager alloc] init];
    });
    return _sharedInstance;
}

-(void)authorize {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil
                                       completion:^(BOOL granted, NSError *error) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (!granted) {
                                                   [self.delegate credentialManagerSucceeded:NO];
                                                   return;
                                               }
                                               
                                               NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                                               if ([accountsArray count] == 0) {
                                                   [self.delegate credentialManagerNoAccounts];
                                                   return;
                                               }
                                               
                                               [self.delegate credentialManagerAuthorizedAccounts:accountsArray];
                                           });
                                       }];
}

@end
