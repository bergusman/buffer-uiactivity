//
//  PostUpdateService.m
//  Buffer
//
//  Created by Andrew Yates on 08/10/2011.
//  Copyright (c) 2011 Buffer, Inc. All rights reserved.
//

#import "PostUpdateService.h"
#import "AFJSONRequestOperation.h"
#import "NSString+Encode.h"

@implementation PostUpdateService

-(void)postUpdate:(NSString *)update_text forProfiles:(NSArray *)profiles sendNow:(BOOL)now withSender:(id)sender {
    NSString *access_token = [[NSUserDefaults standardUserDefaults] stringForKey:@"buffer_accesstoken"];
    
    NSString *url = [NSString stringWithFormat:@"https://api.bufferapp.com/1/updates/create.json?access_token=%@", access_token];
    
    NSString *formatted_update = [update_text encodeString:NSUTF8StringEncoding];
    
    NSString *params = @"";
    if(now){
        params = [NSString stringWithFormat:@"text=%@&now=1&shorten=true&profile_ids[]=%@", formatted_update, [profiles componentsJoinedByString:@"&profile_ids[]="]];
    } else {
        params = [NSString stringWithFormat:@"text=%@&shorten=true&profile_ids[]=%@", formatted_update, [profiles componentsJoinedByString:@"&profile_ids[]="]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([[JSON valueForKey:@"status"] boolValue]){
            [sender performSelector:@selector(updatePosted)];
        } else {
            [sender performSelector:@selector(errorAddingUpdate:) withObject:[JSON valueForKey:@"message"]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if(JSON){
            [sender performSelector:@selector(errorAddingUpdate:) withObject:[JSON valueForKey:@"message"]];
        } else {
            [sender performSelector:@selector(errorAddingUpdate:) withObject:[[error userInfo] valueForKey:NSLocalizedDescriptionKey]];
        }
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

@end
