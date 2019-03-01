//
//  UITextView+Category.m
//  SXUtil
//
//  Created by apple on 2019/3/1.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "UITextView+Category.h"
#import <objc/runtime.h>
@implementation UITextView (Category)
+(void)load {
    Method oldMethod = class_getInstanceMethod([self class], @selector(initWithFrame:));
    Method newMethod = class_getInstanceMethod([self class], @selector(newInitWithFrame:));
    method_exchangeImplementations(oldMethod, newMethod);
}
-(instancetype)newInitWithFrame:(CGRect)frame {
    
    UITextView *tf = [self newInitWithFrame:frame];
    
    //监听键盘开启关闭通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //键盘顶部添加完成按钮
    [tf p_addFinishBtn];
    
    return tf;
}
#pragma mark - 键盘弹出自适应布局
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSValue *value = [[aNotification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    float keyEnd_y = [value CGRectValue].origin.y;
    float animationDuration = [[aNotification userInfo][@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    
    CGRect screenFrame = [self.superview convertRect:self.frame toView:[UIApplication sharedApplication].keyWindow];
    
    if (CGRectGetMaxY(screenFrame) <= keyEnd_y - 10) {
        return;
    }
    
    CGRect viewFrame = self.superview.frame;
    
    viewFrame.origin.y = (keyEnd_y - 10) - CGRectGetMaxY(screenFrame);
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.superview.frame = viewFrame;
    }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    float animationDuration = [[aNotification userInfo][@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.superview.frame = [[UIScreen mainScreen] bounds];
    }];
}
#pragma mark - 键盘顶部添加完成按钮
-(void)p_addFinishBtn {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.5)];
    bgView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:99.0/255 green:99.0/255 blue:99.0/255 alpha:1];
    [bgView addSubview:line];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0.5, [UIScreen mainScreen].bounds.size.width, 44);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    [btn addTarget:self action:@selector(p_clickFinishBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    
    self.inputAccessoryView = bgView;
}
-(void)p_clickFinishBtnAction {
    [self endEditing:YES];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end