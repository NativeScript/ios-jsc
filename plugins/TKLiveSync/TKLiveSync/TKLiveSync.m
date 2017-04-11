//
//  TKLiveSync.m
//  TKLiveSync
//
//  Created by Tsvetan Raikov on 6/16/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import "TKLiveSync.h"
#include "unzip.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import <notify.h>

static void tryExtractLiveSyncArchive()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString* liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString* syncZipPath = [NSString pathWithComponents:@[ liveSyncPath, @"sync.zip" ]];
    NSString* appPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];

    NSError* err;
    
    if ([fileManager fileExistsAtPath:syncZipPath]) {
        if ([fileManager fileExistsAtPath:appPath]) {
            [fileManager removeItemAtPath:appPath error:&err];
            if (err) {
                NSLog(@"Can't remove %@: %@", appPath, err);
            }
        }
        
        NSLog(@"Unzipping LiveSync folder. This could take a while...");
        NSDate* startDate = [NSDate date];
        int64_t unzippedFilesCount = unzip(syncZipPath.UTF8String, liveSyncPath.UTF8String);
        NSLog(@"Unzipped %lld entries in %fms.", unzippedFilesCount, -[startDate timeIntervalSinceNow] * 1000);
        
        [fileManager removeItemAtPath:syncZipPath error:&err];
        if (err) {
            NSLog(@"Can't remove %@: %@", syncZipPath, err);
        }
    }

    NSString* tnsModulesPath = [appPath stringByAppendingPathComponent:@"tns_modules"];

    // TRICKY: Check if real dir tns_modules exists. If it does not, or it is a symlink, the symlink has to be recreated.
    if ([fileManager fileExistsAtPath:appPath] && ![fileManager fileExistsAtPath:tnsModulesPath]) {
        NSLog(@"tns_modules folder not livesynced. Using tns_modules from the already deployed bundle...");
    
        // If tns_modules were a symlink, delete it so it can be linked again, this is necessary when relaunching the app from Xcode after lifesync, the app bundle seems to move.
        [fileManager removeItemAtPath:tnsModulesPath error:nil];

        NSError* error;
        NSString* bundleNativeScriptModulesPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"app/tns_modules"];
        if (![fileManager createSymbolicLinkAtPath:tnsModulesPath withDestinationPath:bundleNativeScriptModulesPath error:&error]) {
            NSLog(@"Failed to symlink tns_modules folder: %@", error);
        }
    }
}

static void trySetLiveSyncApplicationPath()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString* liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString* appPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];
    
    if (![fileManager fileExistsAtPath:appPath]) {
        return; // Don't change the app root folder
    }

    if (setenv("TNSApplicationPath", liveSyncPath.UTF8String, 0) == -1) {
        perror("Could not set application path");
    }
}

static NSURL *availableRestartURL() {
    NSArray *availableSchemesToOpen = NSBundle.mainBundle.infoDictionary[@"LSApplicationQueriesSchemes"];
    NSArray *urlSchemes = [NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"] firstObject][@"CFBundleURLSchemes"];
    NSString *urlQuery = urlSchemes.firstObject ? [NSString stringWithFormat:@"?callbackAppScheme=%@", urlSchemes.firstObject] : @"";
    
    for (NSString *scheme in availableSchemesToOpen) {
        NSURL *restartURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://restartNativeScript%@", scheme, urlQuery]];
        if ([UIApplication.sharedApplication canOpenURL:restartURL]) {
            return restartURL;
        }
    }
    
    return nil;
}

static GCDWebServer* webServer;
static NSString * const kHTMLResponse = @"<html><head><meta http-equiv=\"refresh\""
" content=\"2;url=%@://reload\" /></head><body><p style=\"text-align: center; font-size: 300%%; margin: 50px\">"
"Sync completed successfully.</br><a href=\"%@://reload\">Opening shortly in NativeScript."
"</p><script>var xhttp = new XMLHttpRequest();xhttp.open('RESTART', '/', true);xhttp.send();</script></body></html>\n";

static void restartApp()
{
    NSURL *restartURL = availableRestartURL();
    if (restartURL) {
        [UIApplication.sharedApplication openURL:restartURL];
        exit(0);
    }
    
    BOOL useSafariForRestart = [NSBundle.mainBundle.infoDictionary[@"SafariRestart"] boolValue];
    if(!useSafariForRestart){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Application Restart Required"
                                                        message:@"To view the current changes please restart the application"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // Starting a local web server used for a restart.
    NSArray *bundleURLTypes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"];
    NSString *appScheme = [bundleURLTypes.firstObject[@"CFBundleURLSchemes"] firstObject];
    NSString *html = [NSString stringWithFormat: kHTMLResponse, appScheme, appScheme];
    [GCDWebServer setLogLevel:1];
    if (!webServer) {
        webServer = [[GCDWebServer alloc] init];
        [webServer addDefaultHandlerForMethod:@"GET"
                                 requestClass:[GCDWebServerRequest class]
                                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                     return [GCDWebServerDataResponse responseWithHTML:html];
                                 }];
        
        [webServer addDefaultHandlerForMethod:@"RESTART"
                                 requestClass:[GCDWebServerRequest class]
                                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                     exit(0);
                                 }];
    }
    
    NSError *error;
    NSNumber *port = @(8081);
    NSString *url = [NSString stringWithFormat:@"http://127.0.0.1:%@/1/", port];
    BOOL isServerSuccessfullyStarted = webServer.isRunning;
    
    if (!isServerSuccessfullyStarted) {
        isServerSuccessfullyStarted = [webServer startWithOptions:@{
                                                                    GCDWebServerOption_AutomaticallySuspendInBackground: @(NO),
                                                                    GCDWebServerOption_Port: port
                                                                    }
                                                            error:&error];
    }
    
    if (!isServerSuccessfullyStarted || error) {
        if (!error) {
            error = [NSError errorWithDomain:@"LiveSync"
                                        code:1234
                                    userInfo:@{ NSLocalizedDescriptionKey: @"Failed to restart app." }];
        }
        
        NSLog(@"Error %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot LiveSync"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:url]];
}

static void listenForRestartNotification() {
    
    NSString *restartNotificationName = [NSString stringWithFormat:@"%@:NativeScript.LiveSync.RestartApplication", [[NSBundle mainBundle] bundleIdentifier]];
    
    int restartApplicationSubscription;
    notify_register_dispatch([restartNotificationName UTF8String],
                             &restartApplicationSubscription,
                             dispatch_get_main_queue(),
                             ^(int token) {
        restartApp();
    });
}

__attribute__((constructor)) static void TKLiveSyncInit()
{
    tryExtractLiveSyncArchive();
    trySetLiveSyncApplicationPath();
    listenForRestartNotification();
}
