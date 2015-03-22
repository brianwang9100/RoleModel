//
//  NewModelViewController.m
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "NewModelViewController.h"
#import <MyoKit/MyoKit.h>
#import "ModelGraphViewController.h"
static int MAX_MODELS = 1;
@interface NewModelViewController ()

@end

@implementation NewModelViewController {
    BOOL _recording;
    NSDate *_initialDate;
    NSMutableArray *_modelHolder;
    NSMutableArray *_currentModel;
    
    NSString *_poseString;
    double _roll;
    double _pitch;
    double _yaw;
    double _aX;
    double _aY;
    double _aZ;
    
    TLMMyo *_myo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _syncAndLockLabel.text = @"";
    _recording = false;
    _modelHolder = [[NSMutableArray alloc] initWithCapacity:5];
    
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
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
    _recordButton.hidden = FALSE;
    
    [_recordButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    
    _sampleSizeLabel.hidden = FALSE;
    _syncAndLockLabel.text = @"Perform Sync Gesture";

    
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    _connectButton.hidden = FALSE;
    _recordButton.hidden = TRUE;
    _sampleSizeLabel.hidden = TRUE;
    _syncAndLockLabel.text = @"";
    
}


- (void)didUnlockDevice:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Unlocked";
}

-(void) startRecording {
    
    if ([_modelHolder count] >= MAX_MODELS) {
        [_recordButton setTitle:@"Maxed!" forState:UIControlStateNormal];
        [_recordButton setTitle:@"Maxed!" forState:UIControlStateSelected];
        [_recordButton setTitle:@"Maxed!" forState:UIControlStateDisabled];
    } else {
        _initialDate = [NSDate date];
        _currentModel = [NSMutableArray arrayWithCapacity:300];
        _recording = TRUE;
        _recordButton.selected = TRUE;
        [_recordButton setTitle:@"Recording!" forState:UIControlStateNormal];
        [_recordButton setTitle:@"Recording!" forState:UIControlStateSelected];
        [_recordButton setTitle:@"Recording!" forState:UIControlStateDisabled];
        [_recordButton removeTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(endRecording) forControlEvents:UIControlEventTouchUpInside];
        _syncAndLockLabel.text = @"Unlocked";
        
        [_myo unlockWithType:TLMUnlockTypeHold];
    }
}

-(void) endRecording {
    
    if ([_modelHolder count] < MAX_MODELS) {
        [_modelHolder addObject:_currentModel];
        
    }
    _recording = FALSE;
    
    _recordButton.selected = FALSE;
    [_recordButton setTitle:@"Record Again?" forState:UIControlStateNormal];
    [_recordButton setTitle:@"Record Again?" forState:UIControlStateSelected];
    [_recordButton setTitle:@"Record Again?" forState:UIControlStateDisabled];
    [_recordButton removeTarget:self action:@selector(endRecording) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.hidden = FALSE;
    _sampleSizeLabel.text = [NSString stringWithFormat:@"Sample Size: %i", [_modelHolder count]];
    _syncAndLockLabel.text = @"Locked";
    [_myo lock];
}

- (void)didLockDevice:(NSNotification *)notification {

    
    _syncAndLockLabel.text = @"Locked";

}

- (void)didSyncArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
    _syncAndLockLabel.text = @"Locked";

}

- (void)didUnsyncArm:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Perform Sync Gesture";
}


#pragma mark - Updates
- (void)didReceiveOrientationEvent:(NSNotification *)notification {

}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    // Unlock the Myo whenever we receive a pose
//    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
//        [pose.myo unlockWithType:TLMUnlockTypeTimed];
//    } else {
        // Keeps the Myo unlocked until specified.
        // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
        // TLMUnlockTypeTimed to restart the timer.
        [pose.myo unlockWithType:TLMUnlockTypeHold];
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
//    }
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval executionTime = [currentDate timeIntervalSinceDate: _initialDate];
    int index = (int)(executionTime/.01);
    NSLog(@"%d", index);
    
    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    TLMOrientationEvent *orientationEvent = accelerometerEvent.myo.orientation;
    TLMPose* pose = accelerometerEvent.myo.pose;
    _myo = accelerometerEvent.myo;
    
    if (_recording && index < 299) {
    
        // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
        
        TLMVector3 accelerationVector = accelerometerEvent.vector;
        TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
        
        while ([_currentModel count] < index) {
            NSLog(@"addedSpaceHolders");
            [self addGestureTimeStamp];
        }
        
        _roll = angles.roll.radians;
        _pitch = angles.pitch.radians;
        _yaw = angles.yaw.radians;
        
        _aX = accelerationVector.x;
        _aY = accelerationVector.y;
        _aZ = accelerationVector.z;

        
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
            _recordButton.titleLabel.text = @"Time Limit Reached";
            [pose.myo lock];
        } else {
            [self addGestureTimeStamp];
            NSLog(@"addedNewGesture");

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


-(void) post {
    
}

-(void) get {
    
}

#pragma mark - IBActions

-(IBAction) save {
    Model* temp = [[Model alloc] initWithName:@"LOL" gestureArray:[_modelHolder objectAtIndex:0]];
    
    [self.delegate addModel: temp];
    [self.delegate newModelViewControllerDidClose:self];
}

-(IBAction) connectToMyo {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction) close {
    [self.delegate newModelViewControllerDidClose:self];
}





@end
