//
//  UIImage+NSCoder.m
//  
//
//  Created by Maro Development on 7/10/15.
//
//

#import "UIImage+NSCoder.h"

@implementation UIImage (Extension)
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDataObject:UIImagePNGRepresentation(self)];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return [self initWithData:[decoder decodeDataObject]];
}
@end
