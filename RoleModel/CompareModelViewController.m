//
//  CompareModelViewController.m
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "CompareModelViewController.h"
#import <MyoKit/MyoKit.h>
@interface CompareModelViewController ()

@end

@implementation CompareModelViewController {
    BOOL _recording;
    NSDate *_initialDate;
    NSMutableArray *_currentModel;
    
    NSString *_poseString;
    double _roll;
    double _pitch;
    double _yaw;
    double _aX;
    double _aY;
    double _aZ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _recordLabel.text = @"";
    _syncAndLockLabel.text = @"";
    
    _recording = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - NSNotificationCenter Methods

- (void)didConnectDevice:(NSNotification *)notification {
    _connectButton.hidden = TRUE;
    _recordLabel.hidden = FALSE;
    _recordLabel.text = @"Myo not Synced";
    _syncAndLockLabel.text = @"Perform Sync Gesture";
    
    
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    _connectButton.hidden = FALSE;
    _recordLabel.hidden = TRUE;
    _recordLabel.text = @"";
    _syncAndLockLabel.text = @"";
    
}

- (void)didUnlockDevice:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Unlocked";

    _percentError.hidden = TRUE;
    _recordLabel.text = @"Recording!";
    _recording = true;
    _initialDate = [NSDate date];
    _currentModel = [NSMutableArray arrayWithCapacity:300];
}

- (void)didLockDevice:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Locked";
    _recording = false;
    _recordLabel.text = @"Stopped. Press compare to test accuracy";
    _compareButton.hidden = FALSE;
    
}

- (void)didSyncArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
    _recordLabel.text = @"Unlock myo to begin recording";
    _syncAndLockLabel.text = @"Locked";
    
}

- (void)didUnsyncArm:(NSNotification *)notification {
    _recordLabel.text = @"Myo not Synced";
    _syncAndLockLabel.text = @"Perform Sync Gesture";
}


#pragma mark - Updates
- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    // Unlock the Myo whenever we receive a pose
    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
        [pose.myo unlockWithType:TLMUnlockTypeTimed];
    } else {
        // Keeps the Myo unlocked until specified.
        // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
        // TLMUnlockTypeTimed to restart the timer.
        [pose.myo unlockWithType:TLMUnlockTypeHold];
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
    }
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval executionTime = [currentDate timeIntervalSinceDate: _initialDate];
    int index = (int)(executionTime/.01);
    
    if (_recording && index < 299) {
        
        // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
        TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
        TLMOrientationEvent *orientationEvent = accelerometerEvent.myo.orientation;
        TLMPose* pose = accelerometerEvent.myo.pose;
        
        TLMVector3 accelerationVector = accelerometerEvent.vector;
        TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
        
        while ([_currentModel count] < index) {
            [self addGestureTimeStamp];
        }
        
        _roll = angles.roll.radians;
        _pitch = angles.pitch.radians;
        _yaw = angles.yaw.radians;
        
        _aX = accelerationVector.x;
        _aY = accelerationVector.y;
        _aX = accelerationVector.z;
        
        
        switch (pose.type) {
            case TLMPoseTypeUnknown:
                _poseString = @"Unknown";
                break;
            case TLMPoseTypeRest:
                _poseString = @"Unknown";
                break;
            case TLMPoseTypeDoubleTap:
                _poseString = @"Unknown";
                break;
            case TLMPoseTypeFist:
                _poseString = @"Fist";
                break;
            case TLMPoseTypeWaveIn:
                _poseString = @"WaveIn";
                break;
            case TLMPoseTypeWaveOut:
                _poseString = @"WaveOut";
                break;
            case TLMPoseTypeFingersSpread:
                _poseString = @"FingersSpread";
                break;
        }
        
        if (index >= 299) {
            _recording = FALSE;
            _recordLabel.text = @"Time Limit Reached";
            [pose.myo lock];
        } else {
            [self addGestureTimeStamp];
        }
    }
}

#pragma mark - MISC Functions
-(void) addGestureTimeStamp {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[NSNumber numberWithDouble:_roll] forKey:@"roll"];
    [dict setValue:[NSNumber numberWithDouble:_pitch] forKey:@"pitch"];
    [dict setValue:[NSNumber numberWithDouble:_yaw] forKey:@"yaw"];
    [dict setValue:[NSNumber numberWithDouble:_aX] forKey:@"accelerationX"];
    [dict setValue:[NSNumber numberWithDouble:_aY] forKey:@"accelerationY"];
    [dict setValue:[NSNumber numberWithDouble:_aZ] forKey:@"accelerationZ"];
    [dict setValue: _poseString forKey:@"gesture"];
    
    [_currentModel addObject:dict];
}

-(IBAction) compare {
    
    NSMutableArray *superArray = [NSMutableArray arrayWithObjects:_currentModel,_teacher.gestureArray, nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:superArray options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%d", [jsonString length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://127.0.0.1:9875/gatherData"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//        double d = 0;
//        memcpy(&d, [data bytes], sizeof(d));
//        NSLog(@"%.2f", d);
//        [self displayPercentage: d];
        
    }];
}

-(void) displayPercentage:(double) percent {
    _percentError.hidden = FALSE;
    _percentError.text = [NSString stringWithFormat:@"%.2f", percent];
}

-(IBAction) close {
    [self.delegate compareModelViewControllerDidClose:self];
}

-(IBAction) connectToMyo {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
