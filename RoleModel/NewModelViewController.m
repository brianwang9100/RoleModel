//
//  NewModelViewController.m
//  RoleModel
//
//  Created by Brian Wang on 3/21/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "NewModelViewController.h"
#import <MyoKit/MyoKit.h>

@interface NewModelViewController ()

@end

@implementation NewModelViewController {
    BOOL _recording;
    NSDate *_initialDate;
    NSMutableArray *_modelHolder;
    NSMutableArray *_currentModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recordLabel.text = @"";
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
    _recordLabel.hidden = FALSE;
    _recordLabel.text = @"Myo not Synced";
    _sampleSizeLabel.hidden = FALSE;
    _syncAndLockLabel.text = @"Perform Sync Gesture";

    
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    _connectButton.hidden = FALSE;
    _recordLabel.hidden = TRUE;
    _recordLabel.text = @"";
    _sampleSizeLabel.hidden = TRUE;
    _syncAndLockLabel.text = @"";

}

- (void)didUnlockDevice:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Unlocked";
    if ([_modelHolder count] >= 5) {
        _recordLabel.text = @"Max number of samples reached";
    } else {
        _recordLabel.text = @"Recording!";
        _recording = true;
        _initialDate = [NSDate date];
        _currentModel = [[NSMutableArray alloc] initWithCapacity: 300];
    }
    

}

- (void)didLockDevice:(NSNotification *)notification {
    _syncAndLockLabel.text = @"Locked";
    _recordLabel.text = @"Recording Stopped";
    _recording = false;
    if ([_modelHolder count] < 5) {
        [_modelHolder addObject:_currentModel];

    }
    if ([_modelHolder count] >= 5) {
        _recordLabel.text = @"Max number of samples reached";
        _saveButton.hidden = FALSE;
    }
    
    _sampleSizeLabel.text = [NSString stringWithFormat:@"Sample Size: %i", [_modelHolder count]];


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
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    // Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
    CATransform3D rotationAndPerspectiveTransform = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity, angles.pitch.radians, -1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, angles.yaw.radians, 0.0, 1.0, 0.0)), CATransform3DRotate(CATransform3DIdentity, angles.roll.radians, 0.0, 0.0, -1.0));
    
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    // Get the acceleration vector from the accelerometer event.
    TLMVector3 accelerationVector = accelerometerEvent.vector;
    
    // Calculate the magnitude of the acceleration vector.
    float magnitude = TLMVector3Length(accelerationVector);
    
    /* Note you can also access the x, y, z values of the acceleration (in G's) like below
     float x = accelerationVector.x;
     float y = accelerationVector.y;
     float z = accelerationVector.z;
     */
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeDoubleTap:
            break;
        case TLMPoseTypeFist:
            break;
        case TLMPoseTypeWaveIn:
            break;
        case TLMPoseTypeWaveOut:
            break;
        case TLMPoseTypeFingersSpread:
            break;
    }
    
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

#pragma mark - IBActions

-(IBAction) save {
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
