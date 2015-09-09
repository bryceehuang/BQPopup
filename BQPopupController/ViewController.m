//
//  ViewController.m
//  BQPopupController
//
//  Created by HuangBQ on 15/8/28.
//  Copyright (c) 2015年 HuangBQ. All rights reserved.
//
//  欢迎star     --->  github地址：https://github.com/bingqihuang
//  欢迎关注博客  --->  博客地址：http://bingqihuang.github.io/

#import "ViewController.h"
#import "BQPopupController.h"

@interface ViewController () <BQPopupControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton * btn;

@property (strong, nonatomic) BQPopupController * alertPopup;
@property (strong, nonatomic) BQPopupController * sheetPopup;
@property (strong, nonatomic) BQPopupController * fullScreenPopup;

@property (strong, nonatomic) NSAttributedString * popupTitle;
@property (strong, nonatomic) NSAttributedString * firstTitle;
@property (strong, nonatomic) NSAttributedString * secondTitle;
@property (strong, nonatomic) NSAttributedString * thirdTitle;

@property (strong, nonatomic) UIImage * firstImg;
@property (strong, nonatomic) UIImage * secondImg;
@property (strong, nonatomic) UIImage * thirdImg;

@property (strong, nonatomic) BQButtonAction action;

@property (strong, nonatomic) BQButton * cameraButton;
@property (strong, nonatomic) BQButton * galleryButton;
@property (strong, nonatomic) BQButton * cancelButton;

@property (strong, nonatomic) BQButton * finalButton;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self.btn setTitle:NSLocalizedString(@"btn_title", @"按钮title") forState:UIControlStateNormal];
    
}

- (void)initData {

    NSArray *titleArray = @[@"如果我们相遇，证明你的需求和曾经的我类似。",
                            @"不要急,看这天空多美，放松下吧。",
                            @"给个star：https://github.com/bingqihuang"];
    
    NSMutableArray *imageNames = [[NSMutableArray alloc] initWithCapacity:3];
    NSString *imageName = nil;
    for (int i = 0; i < 3; i++) {
        imageName = [NSString stringWithFormat:@"interduce0%d",i+1];
        [imageNames addObject:imageName];
    }

    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    NSMutableParagraphStyle *titleParagraphStyle = NSMutableParagraphStyle.new;
    titleParagraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    UIColor *textColor = [self colorWithHexString:@"#5F5F5F"];
    
    NSAttributedString *attributeString = nil;
    UIImage *image = nil;
    for (int i = 0; i < 3; i++) {
        attributeString = [[NSAttributedString alloc] initWithString:titleArray[i] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : textColor, NSParagraphStyleAttributeName : paragraphStyle}];
        image = [UIImage imageNamed:imageNames[i]];
        
        if (i==0) {
            self.firstTitle = attributeString;
            self.firstImg = image;
        } else if (i==1) {
            self.secondTitle = attributeString;
            self.secondImg = image;
        } else if (i==2) {
            self.thirdTitle = attributeString;
            self.thirdImg = image;
        }
    }
    
    self.popupTitle = [[NSAttributedString alloc] initWithString:@"BQPopupController" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:20], NSParagraphStyleAttributeName : titleParagraphStyle}];
    
    self.cameraButton = [[BQButton alloc] init];
    [self.cameraButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"star一下" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}] forState:UIControlStateNormal];
    self.cameraButton.backgroundColor = [UIColor blueColor];
    self.cameraButton.buttonHeight = 45.0f;
    self.cameraButton.buttonAction = self.action;
    
    self.galleryButton = [[BQButton alloc] init];
    [self.galleryButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"关注博客"] forState:UIControlStateNormal];
    self.galleryButton.backgroundColor = [UIColor yellowColor];
    self.galleryButton.buttonHeight = 45.0f;
    self.galleryButton.buttonAction = self.action;
    
    self.finalButton = [[BQButton alloc] init];
    [self.finalButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"不要这么小气哦" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : [UIColor blackColor]}] forState:UIControlStateNormal];
    
    self.finalButton.backgroundColor = [UIColor redColor];
    self.finalButton.buttonHeight = 45.0f;
    self.finalButton.buttonAction = self.action;

    
}


- (IBAction)showAlert:(id)sender {
    [self initData];
    
    self.alertPopup = [[BQPopupController alloc] initWithTitle:self.popupTitle andContentArray:@[self.firstTitle,self.firstImg,self.secondTitle,self.secondImg] andButtonArray:nil andFinalButton:self.finalButton];
    self.alertPopup.delegate = self;
    
    self.alertPopup.popupHeight = 350;
    // 显示风格
    self.alertPopup.popupStyle = BQPopupStyleAlert;
    
    [self.alertPopup presentPopupControllerAnimated:YES];
    
}

- (IBAction)showActionSheet:(id)sender {
    [self initData];
    self.sheetPopup = [[BQPopupController alloc] initWithTitle:self.popupTitle andContentArray:@[self.firstTitle,self.firstImg,self.secondTitle,self.secondImg,self.thirdTitle,self.thirdImg] andButtonArray:@[self.cameraButton,self.galleryButton] andFinalButton:self.finalButton];
    self.sheetPopup.delegate = self;
    
    self.sheetPopup.popupHeight = 250;
    
    self.sheetPopup.popupStyle = BQPopupStyleActionSheet;
    
    [self.sheetPopup presentPopupControllerAnimated:YES];
    
}
- (IBAction)showFullScreen:(id)sender {
    [self initData];
    
    self.fullScreenPopup = [[BQPopupController alloc] initWithTitle:self.popupTitle andContentArray:@[self.firstTitle,self.firstImg,self.secondTitle,self.secondImg,self.thirdTitle,self.thirdImg] andButtonArray:@[self.cameraButton,self.galleryButton] andFinalButton:self.finalButton];
    self.fullScreenPopup.delegate = self;

    self.fullScreenPopup.popupStyle = BQPopupStyleFullScreen;
    
    [self.fullScreenPopup presentPopupControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark BQPopControllerDelegate
- (void)controllerWillPresent:(BQPopupController *)controller {
    NSLog(@"BQPopup will present...");
}

- (void)controllerDidPresent:(BQPopupController *)controller {
    NSLog(@"BQPopup is presented...");
}

- (void)controllerWillDismiss:(BQPopupController *)controller {
    NSLog(@"BQPopup will dismiss...");
}
- (void)controllerDidDismiss:(BQPopupController *)controller {
    NSLog(@"BQPopup did dismiss...");
}


@end
