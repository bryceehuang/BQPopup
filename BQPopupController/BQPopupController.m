//
//  BQPopupController.m
//  BQPopupController
//
//  Created by HuangBQ on 15/9/1.
//  Copyright (c) 2015年 HuangBQ. All rights reserved.
//
//  欢迎star     --->  github地址：https://github.com/bingqihuang
//  欢迎关注博客  --->  博客地址：http://bingqihuang.github.io/

#import "BQPopupController.h"
#import <QuartzCore/QuartzCore.h>

#define VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height 
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width



@interface BQPopupController ()

@property (nonatomic, strong) UIWindow *keyWindow;

/* background view */
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIScrollView *scrollView;

/* content view, 
    only supported to NSAttributedString and UIImage
*/
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UITapGestureRecognizer *controllerDismissGesture;

/**
    animation constraints
 */

/**
 *  animation constraint for FullScreen
 */
@property (nonatomic, strong) NSLayoutConstraint *scrollViewConstraintTop;

/**
 *  animation constraint for ActionSheet
 */
@property (nonatomic, strong) NSLayoutConstraint *scrollViewConstraintHeight;

/**
 *  animation constraint for Alert
 */
@property (nonatomic, strong) NSLayoutConstraint *scrollViewConstraintCenterY;

@end

@implementation BQButton


@end

@implementation BQPopupController

- (instancetype)initWithTitle:(NSAttributedString *)popupTitle
              andContentArray:(NSArray *)aContentArr
               andButtonArray:(NSArray *)aButtonArr
               andFinalButton:(BQButton *)aFinalButtn {
    
    self = [super init];
    if (self) {
        _title = popupTitle;
        _contentsArray = aContentArr;
        _buttonArray = aButtonArr;
        _finalButton = aFinalButtn;
        
//        if (aContentArr) {
//            for (id obj in aContentArr) {
//                NSLog(@"obj class:%@", [obj class]);
//                NSAssert([obj class] == [NSAttributedString class] || [obj class] == [UIImage class], @"Object isn't NSAttributedString or UIImage.");
//                NSLog(@"object index:%d",(int)[aContentArr indexOfObject:obj]);
//            }
//        }
//        
//        if (aButtonArr) {
//            for (id btn in aButtonArr) {
//                NSAssert([btn class] == [BQButton class],@"Button items can only be of BQButton.");
//            }
//        }
        
        NSEnumerator *windowsArr = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        // setup window
        for (UIWindow *window in windowsArr) {
            if (window.windowLevel == UIWindowLevelNormal) {
                self.keyWindow = window;
                break;
            }
        }
        
        [self defaultSettings];
        
    }

    return self;
}

#pragma mark Default Settings
- (void)defaultSettings {

    self.popupStyle = BQPopupStyleAlert;
    _dismissOnTouchBackground = YES;
    _showVerticalScrollIndicator = NO;
    _contentBackgroundColor = [UIColor whiteColor];
    _contentInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
    _popupHeight = ScreenHeight - 200;
    _popupWidth = ScreenWidth - 40;
    _cornerRadius = 8.0f;
    _paddingForSubviews = 12.0f;
    _finalButtonPadding = 16.0f;
}

#pragma mark - call this method when initial or refresh
- (void)commonSetup {

    // backgroundView
    self.backgroundView = [[UIView alloc] init];
    [self.backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (self.popupStyle == BQPopupStyleFullScreen) {
        self.backgroundView.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    }
    
    if (self.dismissOnTouchBackground) {
        self.controllerDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped)];
        self.controllerDismissGesture.numberOfTapsRequired = 1;
        [self.backgroundView addGestureRecognizer:self.controllerDismissGesture];

    }
    
    [self.keyWindow addSubview:self.backgroundView];
    
    [self.keyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.keyWindow attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.keyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.keyWindow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.keyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.keyWindow attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.keyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.backgroundView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.keyWindow attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    // scroll view
    self.scrollView = [[UIScrollView alloc] init];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.scrollView.showsVerticalScrollIndicator = _showVerticalScrollIndicator;
    self.scrollView.bounces = YES;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.layer.cornerRadius = (self.popupStyle == BQPopupStyleAlert ? self.cornerRadius :0.0f);
    [self.backgroundView addSubview:self.scrollView];
    
    BOOL statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    self.scrollViewConstraintTop = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:statusBarHidden ? 0 : statusBarFrame.size.height + statusBarFrame.origin.y];
    
    self.scrollViewConstraintCenterY = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    
    if (self.popupStyle == BQPopupStyleFullScreen) {
   
        [self.backgroundView addConstraint:self.scrollViewConstraintTop];
        
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
    } else if (self.popupStyle == BQPopupStyleActionSheet) {
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        
        // self.popupHeight <= CGRectGetHeight(self.keyWindow.frame)/2 ? self.popupHeight : CGRectGetHeight(self.keyWindow.frame)/2
        self.scrollViewConstraintHeight = [NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.backgroundView attribute:NSLayoutAttributeTop multiplier:1.0 constant:(self.popupHeight <= CGRectGetHeight(self.keyWindow.frame)/2 ? self.popupHeight : CGRectGetHeight(self.keyWindow.frame)/2)];
        
        [self.backgroundView addConstraint:self.scrollViewConstraintHeight];
    } else {
        // Height
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.popupHeight]];
        // Width
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.popupWidth]];
        
        [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.backgroundView addConstraint:self.scrollViewConstraintCenterY];

    }
    
    // content view
    self.contentView = [[UIView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = self.contentBackgroundColor;
    self.contentView.layer.cornerRadius = self.scrollView.layer.cornerRadius;
    
    [self.scrollView addSubview:self.contentView];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    // add subviews
    if (self.title) {
        UILabel *titleLabel = [self labelWithAttributeString:self.title];
        [self.contentView addSubview:titleLabel];
    }
    
    if (self.contentsArray) {
        for (id obj in self.contentsArray) {
            if ([obj isKindOfClass:[NSAttributedString class]]) {
                UILabel *label = [self labelWithAttributeString:(NSAttributedString *)obj];
                [self.contentView addSubview:label];
                
            } else if ([obj isKindOfClass:[UIImage class]]) {
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)obj];
                imageView.translatesAutoresizingMaskIntoConstraints = NO;
                imageView.contentMode = UIViewContentModeScaleToFill;
                [imageView sizeToFit];
                
                [self.contentView addSubview:imageView];
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
                
            }
        }
    }
    
    if (self.buttonArray) {
        for (BQButton *btn in self.buttonArray) {
            btn.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self.contentView addSubview:btn];
        }
    }
    
    // constraints for subviews
    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.contentInsets.top]];
        } else {
            UIView *previousView = [self.contentView.subviews objectAtIndex:idx - 1];
            if (previousView) {
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.paddingForSubviews]];
            }
        }
        
        if (idx == self.contentView.subviews.count - 1) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-(self.contentInsets.bottom + self.finalButtonPadding + (self.finalButton ? self.finalButton.buttonHeight : 0.0f))]];
        }
        
        if ([view isKindOfClass:[UIButton class]]) {
            BQButton *btn = (BQButton *)view;
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:btn.buttonHeight]];
         
            [btn addTarget:self action:@selector(buttonDidPressed:) forControlEvents:UIControlEventTouchUpInside];

        }
        
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        } else {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        }
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.contentInsets.left]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.contentInsets.right]];
        
    }];
    
    if (self.finalButton) {
        self.finalButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.finalButton addTarget:self action:@selector(buttonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIView *contentLastView = (UIView *)self.contentView.subviews.lastObject;
        [self.contentView addSubview:self.finalButton];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.finalButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.finalButton.buttonHeight]];
        
        if (contentLastView) {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.finalButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentLastView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.finalButtonPadding]];
        }
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.finalButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.contentInsets.bottom]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.finalButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.contentInsets.left]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.finalButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.contentInsets.right]];
    }
    

}

- (void)buttonDidPressed:(BQButton *)sender {
    if (sender.buttonAction) {
        sender.buttonAction(sender);
    }
    
    [self dismissPopupControllerAnimated:YES];
}

- (void)backgroundViewTapped {
    [self dismissPopupControllerAnimated:YES];
}

#pragma mark - present Controller
- (void)presentPopupControllerAnimated:(BOOL)animated {
    
    if ([self.delegate respondsToSelector:@selector(controllerWillPresent:)]) {
        [self.delegate controllerWillPresent:self];
    }
    
    [self commonSetup];
    [self hidePopupConstraints];
    [self.backgroundView needsUpdateConstraints];
    [self.backgroundView layoutIfNeeded];
    
    [self showPopupConstraints];
  
    [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.scrollViewConstraintTop.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
                         self.backgroundView.alpha = 1.0f;
                         [self.backgroundView needsUpdateConstraints];
                         [self.backgroundView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(controllerDidPresent:)])
                         {
                             [self.delegate controllerDidPresent:self];
                         }
                     }
     ];
    
}

#pragma mark - dismiss Controller
- (void)dismissPopupControllerAnimated:(BOOL)animated {
    
    if ([self.delegate respondsToSelector:@selector(controllerWillPresent:)]) {
        [self.delegate controllerWillDismiss:self];
    }
    
    [self hidePopupConstraints];
    
    [UIView animateWithDuration:animated ? 0.3f : 0.0f delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         self.backgroundView.alpha = 0.0f;
                         [self.backgroundView needsUpdateConstraints];
                         [self.backgroundView layoutIfNeeded];
        
                     }
                     completion:^(BOOL finished) {

                         [self.backgroundView removeFromSuperview];
                         self.contentView = nil;
                         self.scrollView = nil;
                         self.backgroundView = nil;
                         if ([self.delegate respondsToSelector:@selector(controllerDidPresent:)])
                         {
                             [self.delegate controllerDidDismiss:self];
                         }
        
                     }
     ];
    
}

- (void)showPopupConstraints {
    
    switch (self.popupStyle) {
        case BQPopupStyleFullScreen:
            self.scrollViewConstraintTop.constant = self.keyWindow.frame.size.height;
            break;
        case BQPopupStyleActionSheet:
            self.scrollViewConstraintHeight.constant = (self.popupHeight <= CGRectGetHeight(self.keyWindow.frame)/2 ? self.popupHeight : CGRectGetHeight(self.keyWindow.frame)/2);
            break;
        default:
            self.scrollViewConstraintCenterY.constant = 0;
            break;
    }
}

- (void)hidePopupConstraints {
    switch (self.popupStyle) {
        case BQPopupStyleFullScreen:
            self.scrollViewConstraintTop.constant = self.keyWindow.frame.size.height;
            break;
        case BQPopupStyleActionSheet:
            self.scrollViewConstraintHeight.constant = self.keyWindow.frame.size.height;
            break;
        default:
            self.scrollViewConstraintCenterY.constant = -self.keyWindow.frame.size.height;
            break;
    }

}

- (UILabel *)labelWithAttributeString:(NSAttributedString *)attributeStr {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.attributedText = attributeStr;
    label.numberOfLines = 0;
    
    return label;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
