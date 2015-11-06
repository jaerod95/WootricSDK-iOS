//
//  WTRSurveyTests.m
//  WootricSDK
//
//  Created by Łukasz Cichecki on 06/11/15.
//  Copyright © 2015 Wootric. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WTRSurvey.h"
#import "WTRApiClient.h"
#import "WTRDefaults.h"

@interface WTRSurveyTests : XCTestCase

@property (nonatomic, strong) WTRApiClient *apiClient;
@property (nonatomic, strong) WTRSurvey *surveyClient;

@end

@interface WTRSurvey (Tests)

- (BOOL)needsSurvey;

@end

@implementation WTRSurveyTests

- (void)setUp {
  [super setUp];
  _apiClient = [WTRApiClient sharedInstance];
  _surveyClient = [[WTRSurvey alloc] init];
}

- (void)tearDown {
  [super tearDown];
  _apiClient.settings.externalCreatedAt = nil;
  _apiClient.settings.surveyImmediately = NO;
  _apiClient.settings.firstSurveyAfter = @0;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:NO forKey:@"surveyed"];
  [defaults setDouble:0 forKey:@"lastSeenAt"];
}

// surveyImmediately = YES
- (void)testNeedsSurveyOne {
  _apiClient.settings.surveyImmediately = YES;
  XCTAssertTrue([_surveyClient needsSurvey]);
}

// surveyImmediately = YES, surveyed = YES
- (void)testNeedsSurveyTwo {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:@"surveyed"];
  _apiClient.settings.surveyImmediately = YES;
  XCTAssertFalse([_surveyClient needsSurvey]);
}

// firstSurveyAfter = 31, externalCreatedAt = 32
- (void)testNeedsSurveyThree {
  _apiClient.settings.firstSurveyAfter = @31;
  _apiClient.settings.externalCreatedAt = [self createdDaysAgo:32]; // 32 days ago
  XCTAssertTrue([_surveyClient needsSurvey]);
}

// firstSurveyAfter = 0, surveyed = N0
- (void)testNeedsSurveyFour {
  _apiClient.settings.externalCreatedAt = [self createdDaysAgo:32]; // 32 days ago
  XCTAssertTrue([_surveyClient needsSurvey]);
}

// firstSurveyAfter = 0, surveyed = YES
- (void)testNeedsSurveyFive {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:@"surveyed"];
  _apiClient.settings.externalCreatedAt = [self createdDaysAgo:32]; // 32 days ago
  XCTAssertFalse([_surveyClient needsSurvey]);
}

// surveyed > 90 days
- (void)testNeedsSurveySix {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:@"surveyed"];
  [defaults setDouble:[[self createdDaysAgo:91] doubleValue] forKey:@"surveyedAt"];
  [WTRDefaults checkIfSurveyedDefaultExpired];
  XCTAssertTrue([_surveyClient needsSurvey]);
}

// surveyed = NO, surveyImmediately = NO, firstSurveyAfter = 60, externalCreatedAt = 20, lastSeenAt = 40
- (void)testNeedsSurveySeven {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setDouble:[[self createdDaysAgo:40] doubleValue] forKey:@"lastSeenAt"];
  _apiClient.settings.firstSurveyAfter = @60;
  _apiClient.settings.externalCreatedAt = [self createdDaysAgo:20];
  XCTAssertFalse([_surveyClient needsSurvey]);
}

// surveyed = NO, surveyImmediately = NO, firstSurveyAfter = 31, externalCreatedAt = 20, lastSeenAt = 40
- (void)testNeedsSurveyEight {
  _apiClient.settings.firstSurveyAfter = @31;
  _apiClient.settings.externalCreatedAt = [self createdDaysAgo:20];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setDouble:[[self createdDaysAgo:40] doubleValue] forKey:@"lastSeenAt"];
  XCTAssertTrue([_surveyClient needsSurvey]);
}

- (NSNumber *)createdDaysAgo:(int)daysAgo {
  return [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] - (daysAgo * 60 * 60 * 24)];
}

@end