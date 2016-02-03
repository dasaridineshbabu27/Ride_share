//
//  CustomAnnotation.m
//  RideShare
//
//  Created by Reddy on 27/01/16.
//  Copyright © 2016 Reddy. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"CustomAnnotationView" owner:self options:nil] objectAtIndex:0]];
    }
    return self; }

@end
