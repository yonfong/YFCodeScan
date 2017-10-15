//
//  YFScanPreviewView.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanPreviewView.h"

@interface YFScanPreviewView()

@property (nonatomic, strong) YFScanPreviewViewConfiguration *configuration;

@property (nonatomic,assign) CGRect scanCrop;

@end

@implementation YFScanPreviewView

-(instancetype)initWithFrame:(CGRect)frame configuration:(YFScanPreviewViewConfiguration*)configuration
{
    if (self = [super initWithFrame:frame])
    {
        self.configuration = configuration;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)startScanningAnimation
{
    
}

- (void)stopScanningAnimation
{
    
}


- (void)drawRect:(CGRect)rect
{
    int marginLeft = _configuration.scanCropXMargin;
    
    CGRect innerRect = CGRectInset(rect, marginLeft, marginLeft);
    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += marginLeft;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y   += (rect.size.height - minSize) / 2 - rect.size.height / 6;
        innerRect.size.height = minSize;
    }
    CGFloat centerYOffset = _configuration.scanCropCenterYOffset;
    CGRect scanCrop = CGRectOffset(innerRect, 0, centerYOffset);
    self.scanCrop = scanCrop;
    
    [self addOuterLayer];
    [self addScanCropLayer];
    [self addScanCropAngleLayer];
}

- (void)addOuterLayer
{
    const CGFloat *components = CGColorGetComponents(_configuration.scanCropOuterFillColor.CGColor);
    
    CGFloat colorOfRed = components[0];
    CGFloat colorOfGreen = components[1];
    CGFloat colorOfBlue = components[2];
    CGFloat colorOfAlpa = components[3];
    UIColor *fillColor = [UIColor colorWithRed:colorOfRed green:colorOfGreen blue:colorOfBlue alpha:1.0];
    float opacity = colorOfAlpa;
    
    CGRect rect = self.scanCrop;
    
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), rect.origin.y)];
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.origin.y, rect.origin.x, CGRectGetHeight(rect))];
    
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect), rect.origin.y, CGRectGetWidth(self.bounds) - rect.origin.x - CGRectGetWidth(rect), CGRectGetHeight(rect))];
    
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.origin.y + CGRectGetHeight(rect), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - rect.origin.y - CGRectGetHeight(rect))];
    
    [self addShapeLayerWithPath:topPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:leftPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:rightPath fillColor:fillColor opacity:opacity];
    [self addShapeLayerWithPath:bottomPath fillColor:fillColor opacity:opacity];
}


- (void)addScanCropLayer
{
    if (!_configuration.showScanCropBorder) {
        return;
    }
    CGRect rect = self.scanCrop;
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 2.0;
    shapeLayer.borderColor = _configuration.scanCropBorderColor.CGColor;
    shapeLayer.path          = [UIBezierPath bezierPathWithRect:rect].CGPath;;
    [self.layer addSublayer:shapeLayer];
}

- (void)addScanCropAngleLayer
{
    CGRect rect = self.scanCrop;
    
    UIColor *fillColor = _configuration.scanCropAngleLineColor;
    CGFloat angleLineWidth = _configuration.scanCropAngleLineWidth;
    CGFloat angleLineHeight = _configuration.scanCropAngleLineHeight;
    CGFloat angleBorderWidth = 1.0;
    
    CGFloat offset = 0;
    switch (_configuration.scanCropAngleStyle)
    {
        case YFScanCropAngleStyleOuter:
        {
            offset = -angleLineWidth;
        }
            break;
        case YFScanCropAngleStyleOn:
        {
            offset = (angleLineWidth - angleBorderWidth) / 2;;
        }
            break;
        case YFScanCropAngleStyleInner:
        {
            offset = angleBorderWidth;
            
        }
            break;
            
        default:
        {
            offset = angleBorderWidth;
        }
            break;
    }
    
    CGSize pathVerticalSize = CGSizeMake(angleLineWidth, angleLineHeight);
    CGSize pathHorizontalSize = CGSizeMake(angleLineHeight, angleLineWidth);
    
    UIBezierPath *topLeftVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + offset, rect.origin.y + offset, pathVerticalSize.width, pathVerticalSize.height)];
    
    UIBezierPath *topLeftHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + offset, rect.origin.y + offset, pathHorizontalSize.width, pathHorizontalSize.height)];
    
    UIBezierPath *topRightVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) - offset - angleLineWidth, rect.origin.y + offset, pathVerticalSize.width, pathVerticalSize.height)];
    
    UIBezierPath *topRithtHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) - angleLineHeight - offset, rect.origin.y + offset, pathHorizontalSize.width, pathHorizontalSize.height)];
    
    UIBezierPath *bottomLeftVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + offset, rect.origin.y + CGRectGetHeight(rect) - angleLineHeight - offset, pathVerticalSize.width, pathVerticalSize.height)];
    
    UIBezierPath *bottomLeftHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + offset, rect.origin.y + CGRectGetHeight(rect) - offset - angleLineWidth, pathHorizontalSize.width, pathHorizontalSize.height)];
    
    UIBezierPath *bottomRithtVerPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) - offset - angleLineWidth, rect.origin.y +CGRectGetHeight(rect) - angleLineHeight - offset, pathVerticalSize.width, pathVerticalSize.height)];
    
    UIBezierPath *bottomRithtHorPath = [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + CGRectGetWidth(rect) - angleLineHeight - offset, rect.origin.y +CGRectGetHeight(rect) - offset - angleLineWidth, pathHorizontalSize.width, pathHorizontalSize.height)];
    
    [self addShapeLayerWithPath:topLeftVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topLeftHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topRightVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:topRithtHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomLeftVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomLeftHorPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomRithtVerPath fillColor:fillColor opacity:1.0];
    [self addShapeLayerWithPath:bottomRithtHorPath fillColor:fillColor opacity:1.0];
}

- (void)addShapeLayerWithPath:(UIBezierPath *)path fillColor:(UIColor *)color opacity:(float)opacity {
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor     = color.CGColor;
    shapeLayer.opacity       = opacity;
    shapeLayer.path          = path.CGPath;
    [self.layer addSublayer:shapeLayer];
}

@end
