//
//  YFScanPreviewView.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanPreviewView.h"
#import "YFScanningLineAnimation.h"

@interface YFScanPreviewView()

@property (nonatomic, strong) YFScanPreviewViewConfiguration *configuration;

@property (nonatomic, assign, readonly) CGRect scanCrop;

@end

@implementation YFScanPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    YFScanPreviewViewConfiguration *defaultConfiguration = [[YFScanPreviewViewConfiguration alloc] init];
    return [self initWithFrame:frame configuration:defaultConfiguration];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(YFScanPreviewViewConfiguration*)configuration
{
    if (self = [super initWithFrame:frame])
    {
        self.configuration = configuration;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (instancetype)defaultPreview {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (void)startScanningAnimation
{
    if (self.configuration.scanningAnimationItem) {
        CGRect limitRect = self.scanCrop;
        [self.configuration.scanningAnimationItem startAnimationInView:self limitRect:limitRect];
    }
}

- (void)stopScanningAnimation
{
    if (self.configuration.scanningAnimationItem) {
        [self.configuration.scanningAnimationItem stopAnimation];
    }
}


- (void)drawRect:(CGRect)rect
{
    [self addOuterLayer];
    [self addScanCropLayer];
    [self addScanCropAngleLayer];
    [self addTipTextLayer];
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
    shapeLayer.lineWidth = _configuration.scanCropBorderWidth;
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = _configuration.scanCropBorderColor.CGColor;
    shapeLayer.path          = [UIBezierPath bezierPathWithRect:rect].CGPath;;
    [self.layer addSublayer:shapeLayer];
}

- (void)addScanCropAngleLayer
{
    CGRect rect = self.scanCrop;
    
    UIColor *fillColor = _configuration.scanCropAngleLineColor;
    CGFloat angleLineWidth = _configuration.scanCropAngleLineWidth;
    CGFloat angleLineHeight = _configuration.scanCropAngleLineHeight;
    CGFloat angleBorderWidth = _configuration.scanCropBorderWidth;
    
    CGFloat offset = 0;
    switch (_configuration.scanCropAngleStyle)
    {
        case YFScanCropAngleStyleOuter:
        {
            offset = -angleLineWidth + angleBorderWidth;
        }
            break;
        case YFScanCropAngleStyleOn:
        {
            offset = (-angleLineWidth + angleBorderWidth) / 2;;
        }
            break;
        case YFScanCropAngleStyleInner:
        {
            offset = 0;
            
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

- (void)addTipTextLayer
{
    NSString *tipText = self.configuration.tipText;
    if (!tipText) {
        return;
    }
    CGSize textSize = [self calculateTitleSizeWithString:tipText];
    
    CATextLayer *textLayer = [CATextLayer new];
    textLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    textLayer.string = tipText;
    textLayer.fontSize = 12;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.truncationMode = kCATruncationEnd;
    textLayer.foregroundColor = [UIColor whiteColor].CGColor;
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    
    CGRect rect = self.scanCrop;
    
    textLayer.position = CGPointMake(rect.origin.x + CGRectGetWidth(rect) / 2, rect.origin.y + CGRectGetHeight(rect) + textSize.height);
    
    [self.layer addSublayer:textLayer];
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(ceilf(size.width)+2, size.height);
}

- (void)addShapeLayerWithPath:(UIBezierPath *)path fillColor:(UIColor *)color opacity:(float)opacity {
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.fillColor     = color.CGColor;
    shapeLayer.opacity       = opacity;
    shapeLayer.path          = path.CGPath;
    [self.layer addSublayer:shapeLayer];
}

- (CGRect)getScanCropRect {
    return self.scanCrop;
}

- (CGRect)scanCrop {
    CGFloat marginLeft = self.configuration.scanCropXMargin;
    
    CGRect innerRect = CGRectInset(self.bounds, marginLeft, marginLeft);
    CGFloat aspectRatio = self.configuration.scanCropAspectRatio;
    
    if (aspectRatio != 0) {
        CGFloat width = CGRectGetWidth(innerRect);
        CGFloat preHeight = CGRectGetHeight(innerRect);
        CGFloat height = width / aspectRatio;
        
        innerRect.origin.y += (preHeight - height) / 2;
        innerRect.size.height = height;
    }
    
    CGFloat centerYOffset = self.configuration.scanCropCenterYOffset;
    CGRect scanCrop = CGRectOffset(innerRect, 0, centerYOffset);
    return scanCrop;
}

- (CGRect)getRectOfInterest
{
    CGRect previewRect = self.bounds;
    CGFloat marginLeft = _configuration.scanCropXMargin;
    CGRect innerRect = CGRectInset(previewRect, marginLeft, marginLeft);
    CGFloat aspectRatio = _configuration.scanCropAspectRatio;
    
    if (aspectRatio != 0) {
        CGFloat width = CGRectGetWidth(innerRect);
        CGFloat preHeight = CGRectGetHeight(innerRect);
        CGFloat height = width / aspectRatio;
        
        innerRect.origin.y += (preHeight - height) / 2;
        innerRect.size.height = height;
    }
    
    CGFloat centerYOffset = _configuration.scanCropCenterYOffset;
    CGRect scanCrop = CGRectOffset(innerRect, 0, centerYOffset);
    
    //计算兴趣区域
    CGRect rectOfInterest;
    
    //ref:https://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/
    CGSize size = previewRect.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        rectOfInterest = CGRectMake((scanCrop.origin.y + fixPadding)/fixHeight,
                                    scanCrop.origin.x/size.width,
                                    scanCrop.size.height/fixHeight,
                                    scanCrop.size.width/size.width);
        
        
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        rectOfInterest = CGRectMake(scanCrop.origin.y/size.height,
                                    (scanCrop.origin.x + fixPadding)/fixWidth,
                                    scanCrop.size.height/size.height,
                                    scanCrop.size.width/fixWidth);
        
        
    }
    
    return rectOfInterest;
}

//根据矩形区域，获取识别区域
+ (CGRect)getScanRectInRect:(CGRect)previewRect configuration:(YFScanPreviewViewConfiguration*)configuration;
{
    CGFloat marginLeft = configuration.scanCropXMargin;
    
    CGRect innerRect = CGRectInset(previewRect, marginLeft, marginLeft);
    CGFloat aspectRatio = configuration.scanCropAspectRatio;
    
    if (aspectRatio != 0) {
        CGFloat width = CGRectGetWidth(innerRect);
        CGFloat preHeight = CGRectGetHeight(innerRect);
        CGFloat height = width / aspectRatio;
        
        innerRect.origin.y += (preHeight - height) / 2;
        innerRect.size.height = height;
    }
    
    CGFloat centerYOffset = configuration.scanCropCenterYOffset;
    CGRect scanCrop = CGRectOffset(innerRect, 0, centerYOffset);
    
    //计算兴趣区域
    CGRect rectOfInterest;

    //ref:https://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/
    CGSize size = previewRect.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        rectOfInterest = CGRectMake((scanCrop.origin.y + fixPadding)/fixHeight,
                                    scanCrop.origin.x/size.width,
                                    scanCrop.size.height/fixHeight,
                                    scanCrop.size.width/size.width);
        
        
    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        rectOfInterest = CGRectMake(scanCrop.origin.y/size.height,
                                    (scanCrop.origin.x + fixPadding)/fixWidth,
                                    scanCrop.size.height/size.height,
                                    scanCrop.size.width/fixWidth);
        
        
    }
    
    return rectOfInterest;
}


@end
