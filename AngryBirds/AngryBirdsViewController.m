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
    
    //mover cerdo
    UIPanGestureRecognizer *pan2Rec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(process2Pan:)];
    pan2Rec.minimumNumberOfTouches = 2;
    [self.trayView addGestureRecognizer: pan2Rec];
    
    self.trayView.dataSource = self;
    
    self.model.angle = 0;
    self.model.speed = 0;
    self.trayView.zoomValue = 0;
    self.trayView.targetDistance = 338;
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
    
}

- (void)processPan:(UIPanGestureRecognizer *)sender {
    CGPoint currentTrans = [sender translationInView:[sender.view superview]];
    
    CGFloat factor = 3;
    CGFloat currentAngle = 0;
    if(currentTrans.x != 0){
        currentAngle =  -atanf(currentTrans.y / currentTrans.x);
        currentAngle = currentAngle > 1 ? 1 : currentAngle;
        currentAngle = currentAngle < 0 ? 0 : currentAngle;
    }
    CGFloat currentSpeed = sqrtf(currentTrans.x * currentTrans.x + currentTrans.y * currentTrans.y) / factor;
    self.model.angle = currentAngle;
    self.model.speed = currentSpeed;
    
    [self.trayView setNeedsDisplay];
    
}

- (void)process2Pan:(UIPanGestureRecognizer *)sender {
    CGPoint currentTrans = [sender translationInView:[sender.view superview]];
    
    self.trayView.targetDistance += currentTrans.x;
    
    self.trayView.targetDistance = self.trayView.targetDistance > 526 ? 526 : self.trayView.targetDistance;
    self.trayView.targetDistance = self.trayView.targetDistance < 150 ? 150 : self.trayView.targetDistance;
    
    [sender setTranslation:CGPointZero inView:sender.view];
    
    [self.trayView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ejectBird:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.buttonReset setEnabled:YES];
    [self.trayView setUserInteractionEnabled:NO];
    [self compruebaResultado];
    [self.labelResult setHidden:NO];
}

- (IBAction)resetGame:(UIButton *)sender {
    [sender setEnabled:NO];
    [self.buttonEject setEnabled:YES];
    [self.labelResult setHidden:YES];
    [self.trayView setUserInteractionEnabled:YES];
    self.model.angle = 0;
    self.model.speed = 0;
    self.trayView.zoomValue = 0;
    self.trayView.targetDistance = 338;
    [self.trayView setNeedsDisplay];
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
