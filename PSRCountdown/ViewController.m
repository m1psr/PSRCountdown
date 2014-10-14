//
//  ViewController.m
//  PSRCountdown
//
//  Created by M on 14.10.14.
//  Copyright (c) 2014 M. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *_dataComponent;
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UIPickerView *countdownPicker;

@property (weak, nonatomic) IBOutlet UIButton *countdownButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

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
    
    self.countdownButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.resetButton.enabled = NO;
}

- (void)p_setZeroOnTheTimer
{
    [self p_setValueOnTheTimeWithMin:0 andSec:0];
}

- (void)p_doSomething
{
    ;
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *r = [(NSNumber *)(_dataComponent[row]) stringValue];
    return [r stringByAppendingString:(component ? @" sec" : @" min")];
}

#pragma mark - IBAcion Methods

- (IBAction)countdownButtonTapped:(UIButton *)sender {
    sender.enabled = NO;
    self.stopButton.enabled = YES;
    self.resetButton.enabled = YES;
    
    [self p_countdown];
}

- (IBAction)stopButtonTapped {
    [self p_resetTheTimer];
}

- (IBAction)resetButtonTapped {
    [self p_setZeroOnTheTimer];
}

@end
