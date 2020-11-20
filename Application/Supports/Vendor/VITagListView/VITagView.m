//
//  FAVTagView.m
//  Tools
//
//  Created by 冯鸿杰 on 2018/6/8.
//  Copyright © 2018年 vimfung. All rights reserved.
//

#import "VITagView.h"

@implementation VITagView

+ (UIFont *)preferredTagFont
{
//    return [UIFont systemFontOfSize:18];
    return [UIFont fontWithName:@"CashMarket-RegularRounded" size:18];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self _initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self _initView];
    }
    return self;
}


//- (CGRect)editingRectForBounds:(CGRect)bounds
//{
//    CGRect rect = [super editingRectForBounds:bounds];
//    rect.origin.x = 0;
//
//    return rect;
//}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    NSString *temp = [[NSString alloc] initWithFormat:@"%ld %@", self.index + 1 , _text];
    
    NSMutableAttributedString *attri =     [[NSMutableAttributedString alloc] initWithString: temp];
    
    
    NSString *temp2 = [[NSString alloc] initWithFormat:@"%ld", self.index + 1];
    
    if (self.selected == true ) {
        
        UIColor *indexColor =  [UIColor colorWithRed:8 / 255.0
                                               green:10 / 255.0
                                                blue:50 / 255.0
                                               alpha:0.3];
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, temp.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:indexColor range:NSMakeRange(0, temp2.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(temp2.length + 1, temp.length - (temp2.length + 1))];
        
        
        
        self.attributedtext = attri;
    } else {
        UIColor *indexColor =  [UIColor colorWithRed:8 / 255.0
                                               green:10 / 255.0
                                                blue:50 / 255.0
                                               alpha:0.3];
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, temp.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:indexColor range:NSMakeRange(0, temp2.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(temp2.length + 1, temp.length - (temp2.length + 1))];
        
        
        self.attributedtext = attri;
    }
}


- (void) setValue:(NSString*) text isError:(BOOL) isError {
    _text = [text copy];
    
    NSString *temp = [[NSString alloc] initWithFormat:@"%ld %@", self.index + 1 , _text];
    
    NSMutableAttributedString *attri =     [[NSMutableAttributedString alloc] initWithString: temp];
    
    
    NSString *temp2 = [[NSString alloc] initWithFormat:@"%ld", self.index + 1];
    
    if (self.selected == true ) {
        
        UIColor *indexColor =  [UIColor colorWithRed:8 / 255.0
                                               green:10 / 255.0
                                                blue:50 / 255.0
                                               alpha:0.3];
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, temp.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:indexColor range:NSMakeRange(0, temp2.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(temp2.length + 1, temp.length - (temp2.length + 1))];
        
        
        self.attributedtext = attri;
    } else {

        UIColor *indexColor =  [UIColor colorWithRed:8 / 255.0
                                               green:10 / 255.0
                                                blue:50 / 255.0
                                               alpha:0.3];
        UIColor *textColor = isError ? [UIColor colorWithRed:250 / 255.0
                                                       green:98 / 255.0
                                                        blue:55 / 255.0
                                                       alpha:1] : [UIColor blackColor];
        
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, temp.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:indexColor range:NSMakeRange(0, temp2.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(temp2.length + 1, temp.length - (temp2.length + 1))];
        
        
        self.attributedtext = attri;
    }
}


- (void)setAttributedtext:(NSMutableAttributedString *)text
{
    _attributedtext = [text copy];
    [self setAttributedTitle:_attributedtext forState:UIControlStateNormal];
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        self.backgroundColor = [UIColor colorWithRed:5 / 255.0
                                               green:82 / 255.0
                                                blue:220 / 255.0
                                               alpha:0.2];
        
        self.layer.borderColor = [UIColor clearColor].CGColor ;
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.borderColor = [UIColor colorWithRed:8 / 255.0
                                                 green:10 / 255.0
                                                  blue:50 / 255.0
                                                 alpha:0.2].CGColor;
    }
}

#pragma mark - Private

- (void)_initView
{
    //    rgba(8,10,50,20)
    self.layer.cornerRadius = 8; //self.frame.size.height * 0.5;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:8 / 255.0
                                             green:10 / 255.0
                                              blue:50 / 255.0
                                             alpha:0.2].CGColor;
    
    self.titleLabel.font = [VITagView preferredTagFont];
    [self setTitleColor:[UIColor colorWithRed:0x82 / 255.0
                                        green:0xc3 / 255.0
                                         blue:0x39 / 255.0
                                        alpha:1]
               forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

@end
