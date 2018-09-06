//
//  SRImageEditorViewController.h
//  ShakeReport
//
//  Created by Jeremy Templier on 1/21/14.
//  Copyright (c) 2014 Jayztemplier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRImageEditorViewController : UIViewController
{
    CGPoint lastPoint;
    
    BOOL mouseSwiped;
    
    int mouseMoved;
    
}
+ (id)controllerWithImage:(UIImage *)image;
@property (weak, nonatomic) IBOutlet UIImageView *screenshotImageView;
@property (strong, nonatomic) UIImage *originalImage;
@property (weak, nonatomic) IBOutlet UISlider *colorSlider;
@property (nonatomic, strong, readonly) CAGradientLayer *layer;
- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
