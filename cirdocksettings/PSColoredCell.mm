#import "PSColoredCell.h"

@implementation PSColoredCell
-(UILabel*)textLabel {
        UILabel* res = [super textLabel];
        res.textColor = (UIColor*)[self.specifier propertyForKey:@"color"];
        NSString *alignment = [self.specifier propertyForKey:@"align"];
        res.textAlignment = [alignment isEqualToString:@"left"]?NSTextAlignmentLeft:([alignment isEqualToString:@"center"]?NSTextAlignmentCenter:([alignment isEqualToString:@"right"]?NSTextAlignmentRight:NSTextAlignmentLeft));
        res.frame = res.superview.bounds;
        return res;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.textLabel.frame = self.textLabel.superview.bounds;
}

@end