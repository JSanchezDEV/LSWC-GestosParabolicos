//
//  AngryBirdsViewController.m
//  AngryBirds
//
//  Created by g102 DIT UPM on 25/02/14.
//  Copyright (c) 2014 g102 DIT UPM. All rights reserved.
//

#import "AngryBirdsViewController.h"
#import "ParabolicModel.h"
#import "AngryBirdsView.h"

@interface AngryBirdsViewController () <MovementModel>
@property (weak, nonatomic) IBOutlet ParabolicModel *model;
@property (weak, nonatomic) IBOutlet AngryBirdsView *trayView;
@property (weak, nonatomic) IBOutlet UISlider *sliderSpeed;
@property (weak, nonatomic) IBOutlet UISlider *sliderAngle;
@property (weak, nonatomic) IBOutlet UISlider *sliderDistance;
@property (weak, nonatomic) IBOutlet UIButton *buttonEject;
@property (weak, nonatomic) IBOutlet UIButton *buttonReset;
@property (weak, nonatomic) IBOutlet UILabel *labelResult;
@end

@implementation AngryBirdsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.trayView.background = self.background;
    self.trayView.bird = self.bird;
    self.trayView.pig = self.pig;
    self.model.gravity = self.gravity;
    
    //zoom
    UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(processPinch:)];
    [self.trayView addGestureRecognizer: pinchRec];
    
    //fuerza y ángulo
    UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(processPan:)];
    [self.trayView addGestureRecognizer: panRec];
    
    self.trayView.dataSource = self;
    [self changeSpeed:self.sliderSpeed];
    [self changeAngle:self.sliderAngle];
    [self changeDistance:self.sliderDistance];
    [self.trayView dibujaBackground];
}

- (void)processPinch:(UIPinchGestureRecognizer *)sender {
    CGFloat factor = sender.scale;
    CGFloat zoomValue = self.trayView.zoomValue;
    //NSLog(@"factor = %f", (factor-1)*100);
    zoomValue += (factor-1)*100;
    
    if (zoomValue >272) self.trayView.zoomValue = 272;
    else if (zoomValue < 1) self.trayView.zoomValue = 1;
    else self.trayView.zoomValue = zoomValue;
    
    sender.scale = 1;
    
    [self.trayView setNeedsDisplay];
    [self.trayView dibujaBackground];
    
}

- (void)processPan:(UIPanGestureRecognizer *)sender {
    CGPoint currentTrans = [sender translationInView:[sender.view superview]];
    CGPoint currentPos = [sender locationInView:[sender.view superview]];
    
    
    [self.trayView setNeedsDisplay];
    [self.trayView dibujaBackground];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.trayView setNeedsDisplay];
    [self.trayView dibujaBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeSpeed:(UISlider *)sender {
    self.model.speed = (sender.value);
    [self.trayView setNeedsDisplay];
}

- (IBAction)changeAngle:(UISlider *)sender {
    self.model.angle = sender.value;
    [self.trayView setNeedsDisplay];
}

- (IBAction)changeDistance:(UISlider *)sender {
    self.trayView.targetDistance = sender.value;
    [self.trayView setNeedsDisplay];
}

- (IBAction)ejectBird:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.sliderSpeed setEnabled:NO];
    [self.sliderAngle setEnabled:NO];
    [self.sliderDistance setEnabled:NO];
    [self.buttonReset setEnabled:YES];
    [self compruebaResultado];
    [self.labelResult setHidden:NO];
}

- (IBAction)resetGame:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.sliderSpeed setEnabled:YES];
    [self.sliderAngle setEnabled:YES];
    [self.sliderDistance setEnabled:YES];
    [self.buttonEject setEnabled:YES];
    [self.labelResult setHidden:YES];
    [self.sliderSpeed setValue:[self valorMedioDeSlider:self.sliderSpeed]];
    [self.sliderAngle setValue:[self valorMedioDeSlider:self.sliderAngle]];
    [self.sliderDistance setValue:[self valorMedioDeSlider:self.sliderDistance]];
    [self viewDidLoad];
}

- (CGFloat)valorMedioDeSlider:(UISlider *)slider{
    return ((slider.maximumValue + slider.minimumValue)/2);
}

- (CGFloat)altureAt:(CGFloat)time{
    return [self.model altureAt: time];
}

- (CGFloat)distanceAt:(CGFloat)time{
    return [self.model distanceAt: time];
    
}

- (CGFloat)duration{
    return [self.model duration];
}

- (void)compruebaResultado{
    CGFloat diferencia = fabsf(self.trayView.targetDistance - [self.model distanceAt:self.model.duration]);
    if(diferencia <= 21){
        [self.labelResult setText:@"GANASTE!"];
        [self.labelResult setTextColor:[UIColor greenColor]];
        
    } else {
        [self.labelResult setText:@"PERDISTE"];
        [self.labelResult setTextColor:[UIColor redColor]];
    }
    [self.labelResult setShadowColor:[UIColor grayColor]];
    [self.labelResult setShadowOffset:CGSizeMake(2, 2)];
}

@end
