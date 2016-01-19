//
//  RSUtils.h
//  RideShare
//
//  Created by Reddy on 13/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSUtils : NSObject

+(NSString*)trimWhiteSpaces:(NSString*)inputString;
+(BOOL)isValidEmail:(NSString *)checkString;

@end
