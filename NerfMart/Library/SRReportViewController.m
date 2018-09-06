//
//  SRReportViewController.m
//  New Relic
//
//  Created by Jeremy Templier on 8/16/13.
//  Copyright (c) 2013 particulier. All rights reserved.
//

#import "SRReportViewController.h"
#import "SRReporter.h"


@interface SRReportViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) UIAlertController *alert;




@end

@implementation SRReportViewController

+ (id)composer
{
    SRReportViewController *controller = [[self alloc] initWithNibName:@"SRReportViewController" bundle:nil];
    controller.delegate = [SRReporter reporter];
    return controller;
}

+ (void)drawBorderAroundTextView:(UITextView *)container
{
    //    UIColor *transBgColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    //    UIColor *black = [UIColor blackColor];
    //    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    //    maskLayer.opacity = 0.8;
    //    maskLayer.colors = [NSArray arrayWithObjects:(id)black.CGColor,
    //                        (id)transBgColor.CGColor, (id)transBgColor.CGColor, (id)black.CGColor, nil];
    //
    //    // Hoizontal - commenting these two lines will make the gradient veritcal
    //    maskLayer.startPoint = CGPointMake(0.0, 0.5);
    //    maskLayer.endPoint = CGPointMake(1.0, 0.5);
    //
    //    NSNumber *gradTopStart = [NSNumber numberWithFloat:0.0];
    //    NSNumber *gradTopEnd = [NSNumber numberWithFloat:0.4];
    //    NSNumber *gradBottomStart = [NSNumber numberWithFloat:0.6];
    //    NSNumber *gradBottomEnd = [NSNumber numberWithFloat:1.0];
    //    maskLayer.locations = @[gradTopStart, gradTopEnd, gradBottomStart, gradBottomEnd];
    //
    //    maskLayer.bounds = container.bounds;
    //    maskLayer.anchorPoint = CGPointZero;
    //    [container.layer addSublayer:maskLayer];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = _sendButton;
    self.titleLabel.layer.borderWidth = 1.0f;
    self.titleLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.messageTextView.layer.borderWidth = 1.0f;
    self.messageTextView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.title = @"Shake Report";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)displayWarningMessage
{
    self.alert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                     message:@"Please enter a title, it is required"
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                          }];
    [self.alert addAction:defaultAction];
    [self presentViewController:self.alert animated:YES completion:nil];
}

- (void)displaySuccessMessage
{
    self.alert = [UIAlertController alertControllerWithTitle:@"Thank You"
                                                     message:@"Your report has successfully been submitted"
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [_delegate reportControllerDidPressSend:self];
                                                              [_alert dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    
    [self.alert addAction:defaultAction];
    [self presentViewController:self.alert animated:YES completion:nil];
}

#pragma mark - Accessors
- (NSString *)title
{
    return _titleLabel.text;
}

- (NSString *)message
{
    return _messageTextView.text;
}

#pragma mark - Actions
- (IBAction)sendPressed:(id)sender
{
    if (_titleLabel.text.length == 0)
    {
        [self displayWarningMessage];
        
    }
    else if(_titleLabel.text.length > 0 && _delegate && [_delegate respondsToSelector:@selector(reportControllerDidPressSend:)]) {
        [self displaySuccessMessage];
    }
}

- (IBAction)cancelPressed:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(reportControllerDidPressCancel:)]) {
        [_delegate reportControllerDidPressCancel:self];
    }
}

#pragma mark - Text Delegate
- (BOOL)textView: _messageTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self.messageTextView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (BOOL)textViewCheck: _titleLabel shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [self.titleLabel resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
