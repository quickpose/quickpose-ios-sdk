#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@class Landmark;
@class QuickPoseMP;

@protocol QuickPoseMediaPipeDelegate <NSObject>
- (void) mediaPipeImpl: (nonnull QuickPoseMP*)mediaPipeImpl poseLandmarks:  (nullable NSArray<NSNumber*> *) poseLandmarks worldPoseLandmarks: (nullable NSArray<NSNumber*> *) worldPoseLandmarks faceLandmarks: (nullable NSArray<NSNumber*> *) faceLandmarks leftHandLandmarks: (nullable NSArray<NSNumber*> *)leftHandLandmarks  rightHandLandmarks: (nullable NSArray<NSNumber*> *)rightHandLandmarks frame: (nullable CVPixelBufferRef) frame timestamp:(CMTime)timestamp absoluteTime:(CFAbsoluteTime) absoluteTime;

@end

@interface QuickPoseMP : NSObject
- (nonnull instancetype)initWithFaceTracking: (BOOL) faceTracking andHandTracking: (BOOL) handTracking;
- (void)startGraphWithModelComplexity: (int) modelComplexity andSmoothLandmarks: (BOOL) smoothLandmarks;
- (void) waitUntilGraphStarted;
- (void)stopGraph;
- (void)processVideoFrame:(nonnull CVPixelBufferRef)imageBuffer timestamp:(CMTime)timestamp absoluteTime:(CFAbsoluteTime) absoluteTime;

@property (readwrite, nonatomic) int rotationDegrees;
@property (readwrite, nonatomic) BOOL handTrackingEnabled;
@property (readwrite, nonatomic) BOOL faceTrackingEnabled;
@property (weak, nonatomic, nullable) id <QuickPoseMediaPipeDelegate> delegate;
@property (readwrite, nonatomic, nonnull) NSString* libVersion;
@property (readwrite, nonatomic, nonnull) NSString* tfVersion;
@property (readwrite, nonatomic, nonnull) NSString* modelWeight;

@end

typedef NS_ENUM(NSInteger, QuickPoseMediaPipeLandmarkJoints) {
      NOSE = 0,
      USER_LEFT_EYE_INNER = 1,
      USER_LEFT_EYE = 2,
      USER_LEFT_EYE_OUTER = 3,
      USER_RIGHT_EYE_INNER = 4,
      USER_RIGHT_EYE = 5,
      USER_RIGHT_EYE_OUTER = 6,
      USER_LEFT_EAR = 7,
      USER_RIGHT_EAR = 8,
      MOUTH_USER_LEFT = 9,
      MOUTH_USER_RIGHT = 10,
      USER_LEFT_SHOULDER = 11,
      USER_RIGHT_SHOULDER = 12,
      USER_LEFT_ELBOW = 13,
      USER_RIGHT_ELBOW = 14,
      USER_LEFT_WRIST = 15,
      USER_RIGHT_WRIST = 16,
      USER_LEFT_PINKY = 17,
      USER_RIGHT_PINKY = 18,
      USER_LEFT_INDEX = 19,
      USER_RIGHT_INDEX = 20,
      USER_LEFT_THUMB = 21,
      USER_RIGHT_THUMB = 22,
      USER_LEFT_HIP = 23,
      USER_RIGHT_HIP = 24,
      USER_LEFT_KNEE = 25,
      USER_RIGHT_KNEE = 26,
      USER_LEFT_ANKLE = 27,
      USER_RIGHT_ANKLE = 28,
      USER_LEFT_HEEL = 29,
      USER_RIGHT_HEEL = 30,
      USER_LEFT_FOOT_INDEX = 31,
      USER_RIGHT_FOOT_INDEX = 32
};
