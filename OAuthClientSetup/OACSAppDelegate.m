//
//  OACSAppDelegate.m
//  OAuthClientSetup
//
//  Created by Douglas Lovell on 1/16/14.
//  Copyright (c) 2014 Telegraphy Interactive. All rights reserved.
//

#import "OACSAppDelegate.h"

@implementation OACSAppDelegate

/*
 Will return nil if not configured.
 @see (void)initConfigurationFrom: (NSDictionary *)config;
 */
- (AFOAuth2Client *)oauthClient {
    if (_oauthClient == nil && self.base_url && self.client_key && self.client_secret) {
        _oauthClient = [AFOAuth2Client clientWithBaseURL:self.base_url
                                                clientID:self.client_key
                                                  secret:self.client_secret];
    }
    return _oauthClient;
}

- (void)netStatusChanged:(AFNetworkReachabilityStatus) status {
    self.networkAvailable = status;
}

- (void)notifyNetworkStatusObservers {

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *config = nil;
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"oauth_setup" ofType:@"plist"];
    if (configPath)
    {
        config = [self readDictionaryFromConfig:configPath];
    }
    if (config) {
        [self initConfigurationFrom:config];
    }
    if (self.httpClient) {
        self.networkAvailable = [self.httpClient networkReachabilityStatus];
        [self.httpClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Network status change to %d", status);
            // avoid warning about creating a retain cycle with self
            OACSAppDelegate *app = (OACSAppDelegate *)([UIApplication sharedApplication].delegate);
            app.networkAvailable = status;
            [app notifyNetworkStatusObservers];
        }];
    }
    return YES;
}

- (void)initConfigurationFrom: (NSDictionary *)config {
    self.auth_path = [config objectForKey:@"auth_path"];
    self.token_path = [config objectForKey:@"token_path"];
    NSString *callback_str = [config objectForKey:@"callback_url"];
    self.callback_url = callback_str ? [NSURL URLWithString:callback_str] : nil;
    NSString * base_str = [config objectForKey:@"base_url"];
    self.base_url = base_str ? [NSURL URLWithString:base_str] : nil;
    self.client_key = [config objectForKey:@"client_key"];
    self.client_secret = [config objectForKey:@"client_secret"];
}

- (NSDictionary *)readDictionaryFromConfig: (NSString *)configPath
{
    NSString *errorDesc = nil;
    NSData *configXML = [[NSFileManager defaultManager] contentsAtPath:configPath];
    NSDictionary *config = (NSDictionary *)[NSPropertyListSerialization
                                            propertyListFromData:configXML
                                            mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                            format:NULL
                                            errorDescription:&errorDesc];
    if (!config) {
        NSLog(@"Error reading config is '%@'", errorDesc);
    }
    return config;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
