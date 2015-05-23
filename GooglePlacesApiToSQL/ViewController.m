//
//  ViewController.m
//  GooglePlacesApiToSQL
//
//  Created by Souvick Ghosh on 23/05/15.
//  Copyright (c) 2015 Teknowledge Software. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>


//******************************************************************************//
//                                                                              //
//      For url keys, status, json structure explanation                        //
//      Go to : https://developers.google.com/places/webservice/search          //
//                                                                              //
//      For this example i am searching restaurant|night_club|bar in sydney     //
//      And my insert query is like that                                        //
//                                                                              //
//      INSERT INTO `venue`( `cityid`, `hostid`, `latitude`, `longitude`,       //
//      `openingtime`, `closingtime`, `type`, `address`, `description`,         //
//      `venuename`, `isvisible`, `capacity`, `ispublic`) VALUES                //
//      ([value-1],[value-2],[value-3],[value-4],[value-5],[value-6],[value-7], //
//      [value-8],[value-9],[value-10],[value-11],[value-12],[value-13])        //
//                                                                              //
//******************************************************************************//

#define URL @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=5000&key=YOUR_API_KEY&type=restaurant|night_club|bar"


@interface ViewController ()
{
    NSString * strQueryString;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    strQueryString=@"INSERT INTO `venue`( `cityid`, `hostid`, `latitude`, `longitude`, `openingtime`, `closingtime`, `type`, `address`, `description`, `venuename`, `isvisible`, `capacity`, `ispublic`) VALUES ";
    
    [self getData:^(id response, NSError *error, NSInteger statusCode) {
        if(response){
            [self breakDataFromResponse:response];
        }
    } withNextPageToken:@"na"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 ----------------------------------------------------------------
|                                                                |
| This function will be used to get the data from the google api |
|                                                                |
 ----------------------------------------------------------------
 */

- (void)getData:(void(^)(id response,NSError *error,NSInteger statusCode))completionHandler withNextPageToken:(NSString *)nextPageToken {
    
    NSString *url;
    if([nextPageToken isEqualToString:@"na"]){
        url=URL;
    }
    else{
        url=[NSString stringWithFormat:@"%@&pagetoken=%@",URL,nextPageToken];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 
    [manager GET:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionHandler(responseObject,nil,operation.response.statusCode);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil,error,operation.response.statusCode);
        NSLog(@"\n\n\n--------Unable To Fetch--------\n\n\n%@\n\n\n%@\n\n\n--------",error,operation.responseString);
    }];
}

/*
 --------------------------------------------------------------------
|                                                                    |
| This function will break the json and make the actual insert query |
|                                                                    |
 --------------------------------------------------------------------
 */

- (void)breakDataFromResponse:(id)response {
    if([[response valueForKey:@"status"] isEqualToString:@"OK"]){
       
        NSArray *arr=[response valueForKey:@"results"];
        
        for(int i=0;i<arr.count;i++){
            
            NSDictionary *tempDic=[arr objectAtIndex:i];
            
            NSString *lat       =[[[tempDic valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"];
            
            NSString *lng       =[[[tempDic valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"];
            
            NSString *name      =[[tempDic valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            NSString *address   =[[tempDic valueForKey:@"vicinity"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            //Make custom row as per your requirement
            NSString *partQuery=[NSString stringWithFormat:@"(5,1,%@,%@,'2015-05-21 00:00:00','2015-05-21 00:00:00','INDOOR','%@','%@','%@',1,150,1),",lat,lng,address,address,name];
            
            //Add it to your main insert query
            strQueryString=[NSString stringWithFormat:@"%@%@",strQueryString,partQuery];
        }
        
        if([response valueForKey:@"next_page_token"]) {
            
            //Adding sleep to make sure google doesn't make it invalid request
            [NSThread sleepForTimeInterval:2.0];
            
            [self getData:^(id response, NSError *error, NSInteger statusCode) {
                if(response){
                    [self breakDataFromResponse:response];
                }
            } withNextPageToken:[response valueForKey:@"next_page_token"]];
        }
        else{
            NSLog(@"\n\n\n-----Fetching Completed-------\n\n\n%@\n\n\n---------------",strQueryString);
        }
    }
    else{
        NSLog(@"\n\n\n------Error------\n\n\n%@\n\n\n------%@\n\n\n------------------",[response valueForKey:@"status"],strQueryString);
    }
}
@end
