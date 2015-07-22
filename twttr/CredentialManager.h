//
//  CredentialManager.h
//  twttr
//
//  Created by Brian Donohue on 7/22/15.
//
//

#import <Foundation/Foundation.h>

@protocol CredentailManagerDelegate <NSObject>

-(void)credentialManagerSucceeded:(BOOL)success;
-(void)credentialManagerNoAccounts;
-(void)credentialManagerAuthorizedAccounts:(NSArray *)array;

@end

@interface CredentialManager : NSObject

+ (CredentialManager *)sharedInstance;
-(void)authorize;
@property (nonatomic, weak) id<CredentailManagerDelegate> delegate;

@end
