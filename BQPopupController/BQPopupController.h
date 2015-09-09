//
//  BQPopupController.h
//  BQPopupController
//
//  Created by HuangBQ on 15/9/1.
//  Copyright (c) 2015年 HuangBQ. All rights reserved.
//
//  欢迎star     --->  github地址：https://github.com/bingqihuang
//  欢迎关注博客  --->  博客地址：http://bingqihuang.github.io/

#import <UIKit/UIKit.h>

@protocol BQPopupControllerDelegate;
@class BQButton;

typedef NS_ENUM(NSUInteger, BQPopupStyle) {
    BQPopupStyleAlert = 0,      // show the popup in an alert
    BQPopupStyleActionSheet,    // show the popup in an action sheet
    BQPopupStyleFullScreen,     // show the popup full screen
};

typedef void(^BQButtonAction) (BQButton *button);

@interface BQPopupController : NSObject

/* View title */
@property (nonatomic, strong) NSAttributedString *title;

/**
 *  BQPopupHeight
 */
@property (nonatomic, assign) CGFloat popupHeight;

@property (nonatomic, assign) CGFloat popupWidth;

/* content view array */
@property (nonatomic, strong) NSArray *contentsArray;

/* buttons in content views */
@property (nonatomic, strong) NSArray *buttonArray;

/* final button in content views, There's a margin to previous view */
@property (nonatomic, strong) BQButton *finalButton;

/* Controller delegate, it will controle the presentation and dismiss of the controller */
@property (nonatomic, weak) id <BQPopupControllerDelegate> delegate;

/*************************************/

/**
 *  The way to show PopupController
 */
@property (nonatomic, assign) BQPopupStyle popupStyle;

/**
 *   Controls whether controller dismiss when touch background. Default Yes.
 */
@property BOOL dismissOnTouchBackground;

/**
 *  Controls whether show scrollview's vertical indicator
 */
@property BOOL showVerticalScrollIndicator;

/**
 *  cornnerRadius of scrollview and contentview
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 *  contentview background color
 */
@property (nonatomic, strong) UIColor *contentBackgroundColor;

@property (nonatomic, assign) UIEdgeInsets contentInsets;

/**
 *  padding for subviews in contentView, default 12.0f
 */
@property (nonatomic, assign) CGFloat paddingForSubviews;

@property (nonatomic, assign) CGFloat finalButtonPadding;

/*************************************/



- (instancetype)initWithTitle:(NSAttributedString *)popupTitle
              andContentArray:(NSArray *)aContentArr
               andButtonArray:(NSArray *)aButtonArr
               andFinalButton:(BQButton *)aFinalButtn;

- (void)presentPopupControllerAnimated:(BOOL)animated;
- (void)dismissPopupControllerAnimated:(BOOL)animated;

@end

@interface BQButton : UIButton

@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) BQButtonAction buttonAction;

@end

@protocol BQPopupControllerDelegate <NSObject>

@optional
- (void)controllerWillPresent:(BQPopupController *)controller;
- (void)controllerDidPresent:(BQPopupController *)controller;
- (void)controllerWillDismiss:(BQPopupController *)controller;
- (void)controllerDidDismiss:(BQPopupController *)controller;

@end





