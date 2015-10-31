#import <Preferences/Preferences.h>

@class UIActivityIndicatorView;

@interface PSSwitchTableCell : PSControlTableCell {
    
    UIActivityIndicatorView* _activityIndicator;
    
}

-(void)setLoading:(BOOL)arg1 ;
-(BOOL)loading;
-(void)dealloc;
-(void)layoutSubviews;
-(void)setValue:(id)arg1 ;
-(void)prepareForReuse;
-(BOOL)canReload;
-(void)reloadWithSpecifier:(id)arg1 animated:(BOOL)arg2 ;
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
-(void)refreshCellContentsWithSpecifier:(id)arg1 ;
-(void)setCellEnabled:(BOOL)arg1 ;
-(id)newControl;
-(id)controlValue;
@end

@interface PSCirDockSwitch : PSSwitchTableCell
@end