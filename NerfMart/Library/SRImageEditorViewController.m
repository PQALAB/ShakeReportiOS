//
//  SRImageEditorViewController.m
//  ShakeReport
//
//  Created by Jeremy Templier on 1/21/14.
//  Copyright (c) 2014 Jayztemplier. All rights reserved.
//

#import "SRImageEditorViewController.h"
#import "SRReportViewController.h"
#import "SRReporter.h"



@interface SRImageEditorViewController ()
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, strong) UIImage *modifiedImage;
@property (nonatomic, assign) NSInteger lineSize;
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *squareButton;
@property (weak, nonatomic) IBOutlet UIButton *dropperButton;
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (nonatomic) BOOL drawActive;

@end

@implementation SRImageEditorViewController

NSUndoManager *undoManager;

+ (id)controllerWithImage:(UIImage *)image
{
    SRImageEditorViewController *controller = [[self alloc] initWithNibName:@"SRImageEditorViewController" bundle:nil];
    controller.originalImage = image;
    return controller;
}


- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)name:UIDeviceOrientationDidChangeNotification object:nil];
    UIColor *transBgColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    UIColor *midBlue = [UIColor colorWithRed:0.91 green:0.98 blue:1.00 alpha:1.0];
    UIColor *bcBlue = [UIColor colorWithRed:0.80 green:0.95 blue:0.98 alpha:1.0];
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.opacity = 0.8;
    maskLayer.frame = _navBar.bounds;
    maskLayer.colors = @[ (__bridge id)transBgColor.CGColor,
                          (__bridge id)midBlue.CGColor,
                          (__bridge id)bcBlue.CGColor ];
    maskLayer.startPoint = CGPointMake(0.0, 0.5);
    maskLayer.endPoint = CGPointMake(1.0, 0.5);
    [_navBar.layer insertSublayer:maskLayer atIndex:0];
    
    undoManager = [[NSUndoManager alloc] init];
    [super viewDidLoad];
    _toolsView.hidden = YES;
    self.title = @"Screenshot Editor";
    //    [self.colorSlider removeConstraints:self.colorSlider.constraints];
    //    [self.colorSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.colorSlider.transform=CGAffineTransformRotate(self.colorSlider.transform,270.0/180*M_PI);
    self.colorSlider.minimumValue = 0.0f;
    self.colorSlider.maximumValue = 100.0f;
    self.colorSlider.value = 1.0f;
    self.colorSlider.thumbTintColor = _currentColor;
    _lineSize = 3;
    
    
    _screenshotImageView.image = _originalImage;
    _modifiedImage = _originalImage;
    _currentColor = [UIColor blackColor];
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextPressed:)];
    self.navigationItem.rightBarButtonItem = nextButtonItem;
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    //  _screenshotImageView.frame = CGRectMake(0, 0, _toolsView.frame.origin.x, CGRectGetHeight(self.view.bounds));
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews]; //if you want superclass's behaviour...
    // resize your layers based on the view's new frame
    UIColor *transBgColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    UIColor *midBlue = [UIColor colorWithRed:0.91 green:0.98 blue:1.00 alpha:1.0];
    UIColor *bcBlue = [UIColor colorWithRed:0.80 green:0.95 blue:0.98 alpha:1.0];
    CAGradientLayer *maskLayer = [CAGradientLayer layer];
    maskLayer.opacity = 0.8;
    maskLayer.frame = _navBar.bounds;
    maskLayer.colors = @[ (__bridge id)transBgColor.CGColor,
                          (__bridge id)midBlue.CGColor,
                          (__bridge id)bcBlue.CGColor ];
    maskLayer.startPoint = CGPointMake(0.0, 0.5);
    maskLayer.endPoint = CGPointMake(1.0, 0.5);
    [_navBar.layer insertSublayer:maskLayer atIndex:0];
    self.colorSlider.thumbTintColor = _currentColor;
}

- (void) didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        _toolsView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerUndoWithTarget:(id)target
                      selector:(SEL)selector
                        object:(id)anObject;
{}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    if (CGRectContainsPoint(_screenshotImageView.frame, touchLocation))
    {
        lastPoint = [self pointByApplyingRatio:[touch locationInView:_screenshotImageView]];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    mouseSwiped = YES;
    CGPoint currentPoint;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    if (CGRectContainsPoint(_screenshotImageView.frame, touchLocation) && _drawActive == true)
    {
        currentPoint = [self pointByApplyingRatio:[touch locationInView:_screenshotImageView]];
        _modifiedImage = [self imageByDrawingLineBetween:lastPoint and:currentPoint];
        _screenshotImageView.image = _modifiedImage;
    }
    lastPoint = currentPoint;
    mouseMoved++;
    if (mouseMoved >= 10) {
        mouseMoved = 0;
    }
}

- (CGPoint)pointByApplyingRatio:(CGPoint)point
{
    CGSize viewSize = _screenshotImageView.frame.size;
    CGSize imageSize = _originalImage.size;
    CGSize ratioSize = CGSizeMake(viewSize.width/imageSize.width, viewSize.height / imageSize.height);
    return CGPointMake(point.x/ratioSize.width, point.y/ratioSize.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!mouseSwiped) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self.view];
        if (CGRectContainsPoint(_screenshotImageView.frame, touchLocation) && _drawActive == true) {
            _modifiedImage = [self imageByDrawingLineBetween:lastPoint and:lastPoint];
            _screenshotImageView.image = _modifiedImage;
        }
    }
}

- (UIImage *)imageByDrawingLineBetween:(CGPoint)startPoint and:(CGPoint)endPoint
{
    UIGraphicsBeginImageContextWithOptions(_originalImage.size, false, 2);
    [_modifiedImage drawInRect:CGRectMake(0, 0, _originalImage.size.width, _originalImage.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _lineSize);
    [_currentColor setStroke];
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), startPoint.x, startPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), endPoint.x, endPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


- (IBAction)sliderValueChange:(id)sender {
    self.colorSlider.thumbTintColor = _currentColor;
    if (self.colorSlider.value <= 9.09 )
    {
        _currentColor = [UIColor orangeColor];
    }
    else if (self.colorSlider.value <= 18.18 )
    {
        _currentColor = [UIColor yellowColor ];
    }
    else if (self.colorSlider.value <= 27.27 )
    {
        _currentColor = [UIColor greenColor];
    }
    else if (self.colorSlider.value <= 40.50 )
    {
        _currentColor = [UIColor greenColor];
    }
    else if (self.colorSlider.value <= 63.62 )
    {
        _currentColor = [UIColor cyanColor];
    }
    else if (self.colorSlider.value <= 72.72 )
    {
        _currentColor = [UIColor blueColor];
    }
    else if (self.colorSlider.value <= 90.81 )
    {
        _currentColor = [UIColor purpleColor];
    }
    else if (self.colorSlider.value <= 99.99 )
    {
        _currentColor = [UIColor redColor];
    }
}



- (IBAction)clearPressed:(id)sender
{
    _modifiedImage = _originalImage;
    _screenshotImageView.image = _originalImage;
    for(UIView *subview in [self.view subviews]) {
        if(subview.tag== 13) {
            [subview removeFromSuperview];
        } else {
            // Do nothing - not a UIButton or subclass instance
        }
    }
}

- (void)nextPressed:(id)sender
{
    SRReportViewController *controller = [SRReportViewController composer];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"screenshot.png"];
    [UIImagePNGRepresentation(_screenshotImageView.image) writeToFile:filePath atomically:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cancelPressed:(id)sender
{
    [[SRReporter reporter] viewControllerDidPressCancel:self];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




#pragma mark - Line Size


- (IBAction)btnCreateField
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 250, 30) ];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.borderColor = _currentColor.CGColor;
    textField.tag = 13;
    textField.layer.borderWidth = 2;
    textField.userInteractionEnabled = TRUE;
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:16];
    textField.placeholder = @"Text";
    textField.textColor = _currentColor;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(panWasRecognized:)];
    [textField addGestureRecognizer:panner];
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(pinchWasRecognized:)];
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    textField.delegate = self;
    [self.view addSubview:textField];
}

- (IBAction)squareButtonPressed:(id)sender
{
    UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(70, 100, 260, 100)];
    myView.tag = 13;
    myView.backgroundColor = [UIColor clearColor];
    myView.layer.borderWidth = 2;
    myView.layer.borderColor = _currentColor.CGColor;
    myView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(panWasRecognized:)];
    [myView addGestureRecognizer:panner];
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(pinchWasRecognized:)];
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    
    [self.view addSubview:myView];
}

- (IBAction)pinchGestureHandler:(UIPinchGestureRecognizer *)sender
{
    static CGPoint center;
    static CGSize initialSize;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        center = sender.view.center;
        initialSize = sender.view.frame.size;
    }
    sender.view.frame = CGRectMake(0,
                                   0,
                                   initialSize.width * sender.scale,
                                   initialSize.height * sender.scale);
    sender.view.center = center;
}

- (void)panWasRecognized:(UIPanGestureRecognizer *)panner {
    UIView *draggedView = panner.view;
    CGPoint offset = [panner translationInView:draggedView.superview];
    CGPoint center = draggedView.center;
    draggedView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panner setTranslation:CGPointZero inView:draggedView.superview];
}

- (IBAction)dropperButtonPressed:(id)sender
{
    
    if ( _drawActive == YES ) {
        _drawActive = NO;
    }
    else if ( _drawActive == NO ) {
        _drawActive = YES;
    }
    if ( _toolsView.hidden == YES ) {
        _toolsView.hidden = NO;
    }
    else if ( _toolsView.hidden == NO ) {
        _toolsView.hidden = YES;
    }
}
@end
