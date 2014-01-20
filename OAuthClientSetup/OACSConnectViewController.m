//
//  OACSConnectViewController.m
//  OAuthClientSetup
//
//  Created by Douglas Lovell on 1/16/14.
//  Copyright (c) 2014 Telegraphy Interactive. All rights reserved.
//

#import "OACSConnectViewController.h"
#import "OACSConfigureViewController.h"
#import "AFOAuth2Client.h"
#import "OACSAppDelegate.h"

@interface OACSConnectViewController ()
@end

@implementation OACSConnectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.errorLabel setHidden:YES];
    [self.password setDelegate:self];
    [self.userName setDelegate:self];
    OACSAppDelegate *app = (OACSAppDelegate *)([UIApplication sharedApplication].delegate);
    [self updateStatus:app.networkAvailable];
    [app addObserver:self
              forKeyPath:@"networkAvailable"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
}

- (void)updateStatus:(AFNetworkReachabilityStatus)status {
    if (status == AFNetworkReachabilityStatusNotReachable) {
        self.liveLabel.text = @"Network not available";
        [self.connectButton setEnabled:NO];
    }
    else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        self.liveLabel.text = @"Networked using WiFi";
        [self.connectButton setEnabled:YES];
    }
    else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        self.liveLabel.text = @"Networked using Cellular Wireless";
        [self.connectButton setEnabled:YES];
    }
    else {
        self.liveLabel.text = @"Network status unavailable";
        [self.connectButton setEnabled:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"networkAvailable"]) {
        OACSAppDelegate *app = (OACSAppDelegate *)([UIApplication sharedApplication].delegate);
        [self updateStatus:app.networkAvailable];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendGrantRequest
{
    if (self.liveLabel) {
        [self.liveLabel resignFirstResponder];
        self.liveLabel = nil;
    }
    [self.connectButton setEnabled:NO];
    NSString *pwd = [self.password text];
    NSString *email = [self.userName text];
    if (pwd && 0 < pwd.length && email && 0 < email.length) {
        [self.errorLabel setHidden:YES];
        [self.workinOnIt startAnimating];
//        OACSAppDelegate *app = (OACSAppDelegate *)([UIApplication sharedApplication].delegate);
//        [app.oauthClient
//         authenticateUsingOAuthWithPath:app.auth_path
//         username:email
//         password:pwd
//         scope:nil
//         success:^(AFOAuthCredential *credential) {
//             [AFOAuthCredential storeCredential:credential
//                                 withIdentifier:app.oauthClient.serviceProviderIdentifier];
//             [self.workinOnIt stopAnimating];
//             [self.connectButton setEnabled:YES];
        [(OACSConfigureViewController *)self.parentViewController didConnect];
//         }
//         failure:^(NSError *error) {
//             NSLog(@"OAuth client authorization error: %@", error);
//             self.errorLabel.text = @"Failed to connect using these credentials.";
//             [self.errorLabel setHidden:NO];
//             [self.workinOnIt stopAnimating];
//             [self.connectButton setEnabled:YES];
//         }];
    }
    else {
        [self.errorLabel setHidden:NO];
        self.errorLabel.text = @"Supply email and password";
        [self.connectButton setEnabled:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    self.liveLabel = textField;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    self.liveLabel = nil;
    [textField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    self.liveLabel = nil;
    [textField resignFirstResponder];
    return YES;
}

@end
