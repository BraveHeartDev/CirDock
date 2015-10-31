//
//  UIImage+NSCoder.h
//  
//
//  Created by Maro Development on 7/10/15.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (Extension)
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end