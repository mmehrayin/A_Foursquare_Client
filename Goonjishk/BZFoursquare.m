





/* Mahshid Mehrayin: This class is a modified version of BZFoursquare class
 I modified the class and added a Sqlite database to save the Access Token returned from
 Foursquare after first login. The original class does not support this functionality. So, user have
 to login everytime that opens the application
 */






/*
 * Copyright (C) 2011-2012 Ba-Z Communication Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"


#ifndef __has_feature
#define __has_feature(x) 0
#endif

#if __has_feature(objc_arc)
#error This file does not support Objective-C Automatic Reference Counting (ARC)
#endif

#define kAuthorizeBaseURL       @"https://foursquare.com/oauth2/authorize"

@interface BZFoursquare ()
@property(nonatomic,copy,readwrite) NSString *clientID;
@property(nonatomic,copy,readwrite) NSString *callbackURL;
@end

@implementation BZFoursquare

@synthesize clientID = clientID_;
@synthesize callbackURL = callbackURL_;
@synthesize clientSecret = clientSecret_;
@synthesize version = version_;
@synthesize locale = locale_;
@synthesize sessionDelegate = sessionDelegate_;
@synthesize accessToken = accessToken_;


- (id)init {
    return [self initWithClientID:nil callbackURL:nil];
}

- (id)initWithClientID:(NSString *)clientID callbackURL:(NSString *)callbackURL {
    NSParameterAssert(clientID != nil && callbackURL != nil);
    self = [super init];
    if (self) {
        self.clientID = clientID;
        self.callbackURL = callbackURL;
    }
    
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"tokens.db"]];
    
    filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        
        //Create Database to save the token
        
        [self CreateDB];

        
    }else{
        
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &tokenDB) == SQLITE_OK)
        {
            sqlite3_stmt  *statement;
            NSString *selectSQL = [NSString stringWithFormat: @"SELECT ACCESSTOKEN FROM TOKEN"];
            
            const char *select_stmt = [selectSQL UTF8String];
            
            if(sqlite3_prepare_v2(tokenDB, select_stmt, -1, &statement, nil)==SQLITE_OK)
            {
                while(sqlite3_step(statement)==SQLITE_ROW){
                    char *token = (char *) sqlite3_column_text(statement, 0);
                    self.accessToken = [[NSString alloc] initWithUTF8String:token];
                }
            } else {
                NSLog(@"%d",sqlite3_step(statement));
            }
            sqlite3_finalize(statement);
            sqlite3_close(tokenDB);
        }
        
    }
    
    
    return self;
}

- (void) CreateDB {
    
        
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &tokenDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS TOKEN (ACCESSTOKEN TEXT)";
            
            if (sqlite3_exec(tokenDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to Create table");
            }
            
            sqlite3_close(tokenDB);
            
        } else {
            
            NSLog(@"Failed to open/create database");
        }
    }
    
}

- (void)dealloc {
    self.clientID = nil;
    self.callbackURL = nil;
    self.clientSecret = nil;
    self.version = nil;
    self.locale = nil;
    self.sessionDelegate = nil;
    self.accessToken = nil;
    [super dealloc];
}

- (BOOL)startAuthorization {
    NSMutableArray *pairs = [NSMutableArray array];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:clientID_, @"client_id", @"token", @"response_type", callbackURL_, @"redirect_uri", nil];
    
    for (NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, CFSTR("%:/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
        NSMutableString *pair = [[key mutableCopy] autorelease];
        [pair appendString:@"="];
        [pair appendString:(NSString *)escapedValue];
        [pairs addObject:pair];
        CFRelease(escapedValue);
    }
    NSString *URLString = kAuthorizeBaseURL;
    NSMutableString *mURLString = [[URLString mutableCopy] autorelease];
    [mURLString appendString:@"?"];
    [mURLString appendString:[pairs componentsJoinedByString:@"&"]];
    NSURL *URL = [NSURL URLWithString:mURLString];
    BOOL result = [[UIApplication sharedApplication] openURL:URL];
    if (!result) {
        NSLog(@"*** %s: cannot open url \"%@\"", __PRETTY_FUNCTION__, URL);
    }
    return result;
}

- (BOOL)handleOpenURL:(NSURL *)url {
    if (![[url absoluteString] hasPrefix:callbackURL_]) {
        return NO;
    }
    NSString *fragment = [url fragment];
    NSArray *pairs = [fragment componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *key = [kv objectAtIndex:0];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [parameters setObject:val forKey:key];
    }
    self.accessToken = [parameters objectForKey:@"access_token"];
    
    if([self accessToken] !=nil){
        
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &tokenDB) == SQLITE_OK)
        {
            sqlite3_stmt    *statement;
            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO TOKEN (ACCESSTOKEN) VALUES (\"%@\")", self.accessToken];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(tokenDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"%@",self.accessToken);
            
            } else {
                NSLog(@"Failed");

            }
            sqlite3_finalize(statement);
            sqlite3_close(tokenDB);
        }
        
    }
        
    
    if (accessToken_) {
        if ([sessionDelegate_ respondsToSelector:@selector(foursquareDidAuthorize:)]) {
            [sessionDelegate_ foursquareDidAuthorize:self];
        }
    } else {
        if ([sessionDelegate_ respondsToSelector:@selector(foursquareDidNotAuthorize:error:)]) {
            [sessionDelegate_ foursquareDidNotAuthorize:self error:parameters];
        }
    }
    return YES;
}

- (void)invalidateSession {
    self.accessToken = nil;
    
    
    
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &tokenDB) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        NSString *deleteSQL = [NSString stringWithFormat: @"DELETE FROM TOKEN"];
        
        const char *delete_stmt = [deleteSQL UTF8String];
        
        sqlite3_prepare_v2(tokenDB, delete_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Delete Complete!");
        } else {
            NSLog(@"Delete Error!");
        }
        sqlite3_finalize(statement);
        sqlite3_close(tokenDB);
    }
    
}

- (BOOL)isSessionValid {
    return (accessToken_ != nil);
}

- (BZFoursquareRequest *)requestWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<BZFoursquareRequestDelegate>)delegate {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([self isSessionValid]) {
        [mDict setObject:accessToken_ forKey:@"oauth_token"];
    }
    if (version_) {
        [mDict setObject:version_ forKey:@"v"];
    }
    if (locale_) {
        [mDict setObject:locale_ forKey:@"locale"];
    }
    return [[[BZFoursquareRequest alloc] initWithPath:path HTTPMethod:HTTPMethod parameters:mDict delegate:delegate] autorelease];
}

- (BZFoursquareRequest *)userlessRequestWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<BZFoursquareRequestDelegate>)delegate {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mDict setObject:clientID_ forKey:@"client_id"];
    if (clientSecret_) {
        [mDict setObject:clientSecret_ forKey:@"client_secret"];
    }
    if (version_) {
        [mDict setObject:version_ forKey:@"v"];
    }
    if (locale_) {
        [mDict setObject:locale_ forKey:@"locale"];
    }
    return [[[BZFoursquareRequest alloc] initWithPath:path HTTPMethod:HTTPMethod parameters:mDict delegate:delegate] autorelease];
}

@end
