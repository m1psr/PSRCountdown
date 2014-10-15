//
//  ViewController.m
//  PSRCountdown
//
//  Created by M on 14.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "ViewController.h"

@import AudioToolbox;

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *_dataComponent;
    NSTimer *_timer;
    
    SystemSoundID _timerWakeUpSignal;
    NSTimer *_timerSignalOff;
}

@property (weak, nonatomic) IBOutlet UIPickerView *countdownPicker;

@property (weak, nonatomic) IBOutlet UIButton *countdownButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *soundOffButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.countdownPicker.dataSource = self;
    self.countdownPicker.delegate = self;
    
    NSMutableArray *dataComponent = [NSMutableArray arrayWithCapacity:60];
    for (NSUInteger i = 0; i < 60; i++) {
        NSNumber *digit = [NSNumber numberWithInteger:i];
        [dataComponent addObject:digit];
    }
    _dataComponent = [dataComponent copy];
    
    [self p_refreshButtons];
}

#pragma mark - Private Methods

- (void)p_countdown
{
    if (!_timer) {
        [self p_setTheTimer];
        return;
    }
    
    NSUInteger min = [self.countdownPicker selectedRowInComponent:0];
    NSUInteger sec = [self.countdownPicker selectedRowInComponent:1];
    
    if (!(min || sec)) {
        [self p_resetTheTimer];
        [self p_doSomething];
        return;
    }
    
    if (!sec) {
        --min;
        sec = [_dataComponent count] - 1;
    } else {
        --sec;
    }
    
    [self p_setValueOnTheTimeWithMin:min andSec:sec];
    [self p_refreshButtons];
}

- (void)p_setValueOnTheTimeWithMin:(NSUInteger)min andSec:(NSUInteger)sec
{
    [self.countdownPicker selectRow:min inComponent:0 animated:YES];
    [self.countdownPicker selectRow:sec inComponent:1 animated:YES];
}

- (void)p_setTheTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(p_countdown)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)p_resetTheTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)p_setZeroOnTheTimer
{
    [self p_setValueOnTheTimeWithMin:0 andSec:0];
    [self p_resetTheTimer];
}

- (void)p_doSomething
{
    [self p_playWakeUpSound];
    [self p_refreshButtons];
}

- (void)p_refreshButtons
{
    if (_timer) {
        self.countdownButton.enabled = NO;
        self.stopButton.enabled = YES;
        self.resetButton.enabled = YES;
    } else {
        NSUInteger min = [self.countdownPicker selectedRowInComponent:0];
        NSUInteger sec = [self.countdownPicker selectedRowInComponent:1];
        
        self.countdownButton.enabled = (min || sec) ? YES : NO;
        
        self.stopButton.enabled = NO;
        self.resetButton.enabled = NO;
    }
    
    self.soundOffButton.hidden = _timerSignalOff ? NO : YES;
}

#pragma mark - Play and Stop the WakeUp Signal

- (void)p_playWakeUpSound
{
    // http://stackoverflow.com/questions/9791491/best-way-to-play-simple-sound-effect-in-ios
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"best_wake_up_sound" ofType:@"mp3"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &_timerWakeUpSignal);
    AudioServicesPlaySystemSound(_timerWakeUpSignal);
    
    // call the following function when the sound is no longer used
    // (must be done AFTER the sound is done playing)
    // AudioServicesDisposeSystemSoundID(_timerWakeUpSignal);
    
    NSAssert(!_timerSignalOff, @"_timerSignalOff != nil");
    _timerSignalOff = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                       target:self
                                                     selector:@selector(p_stopWakeUpSound)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)p_stopWakeUpSound
{
    AudioServicesDisposeSystemSoundID(_timerWakeUpSignal);
    [_timerSignalOff invalidate];
    _timerSignalOff = nil;
}

#pragma mark - UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_dataComponent count];
}

#pragma mark - UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *r = [(NSNumber *)(_dataComponent[row]) stringValue];
    return [r stringByAppendingString:(component ? @" sec" : @" min")];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self p_refreshButtons];
}

#pragma mark - IBAcion Methods

- (IBAction)countdownButtonTapped:(UIButton *)sender {
    if (_timerSignalOff) {
        [self p_stopWakeUpSound];
    }
    [self p_countdown];
}

- (IBAction)stopButtonTapped {
    [self p_resetTheTimer];
    [self p_refreshButtons];
}

- (IBAction)resetButtonTapped {
    [self p_setZeroOnTheTimer];
    [self p_refreshButtons];
}

- (IBAction)soundOffButtonTapped {
    [self p_stopWakeUpSound];
    [self p_refreshButtons];
}

@end
