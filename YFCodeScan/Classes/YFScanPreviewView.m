//
//  YFScanPreviewView.m
//  Pods
//
//  Created by sky on 2017/10/14.
//

#import "YFScanPreviewView.h"
#import "YFScanningLineAnimation.h"

@interface YFScanPreviewView ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, strong) CAShapeLayer *interestRectLayer;

@property (nonatomic, strong) CATextLayer *tipTextLayer;

@property (nonatomic, strong) CAShapeLayer *topLeftAngleLayer;

@property (nonatomic, strong) CAShapeLayer *topRightAngleLayer;

@property (nonatomic, strong) CAShapeLayer *bottomLeftAngleLayer;

@property (nonatomic, strong) CAShapeLayer *bottomRightAngleLayer;

@property (nonatomic, assign, readonly) CGRect scanCrop;

@end

@implementation YFScanPreviewView

- (instancetype)initWithFrame:(CGRect)frame {
    YFScanPreviewViewConfiguration *defaultConfiguration = [[YFScanPreviewViewConfiguration alloc] init];
    return [self initWithFrame:frame configuration:defaultConfiguration];
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(YFScanPreviewViewConfiguration *)configuration {
    if (self = [super initWithFrame:frame]) {
        _configuration = configuration;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

+ (instancetype)defaultPreview {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (void)commonInit {
    CGRect rectOfInterest = self.scanCrop;
    self.maskLayer = [[CAShapeLayer alloc] init];
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    [self.layer addSublayer:self.maskLayer];

    self.interestRectLayer = [[CAShapeLayer alloc] init];
    self.interestRectLayer.path = [[UIBezierPath bezierPathWithRect:rectOfInterest] CGPath];
    self.interestRectLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.interestRectLayer];

    self.tipTextLayer = [[CATextLayer alloc] init];
    self.tipTextLayer.fontSize = 13;
    self.tipTextLayer.alignmentMode = kCAAlignmentCenter;
    self.tipTextLayer.truncationMode = kCATruncationEnd;
    self.tipTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
    self.tipTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer addSublayer:self.tipTextLayer];

    self.topLeftAngleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.topLeftAngleLayer];

    self.topRightAngleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.topRightAngleLayer];

    self.bottomLeftAngleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.bottomLeftAngleLayer];

    self.bottomRightAngleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:self.bottomRightAngleLayer];
}

- (void)startScanningAnimation {
    if (self.configuration.scanningAnimationItem) {
        CGRect limitRect = self.scanCrop;
        [self.configuration.scanningAnimationItem startAnimationInView:self limitRect:limitRect];
    }
}

- (void)stopScanningAnimation {
    if (self.configuration.scanningAnimationItem) {
        [self.configuration.scanningAnimationItem stopAnimation];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        self.frame = self.superview.bounds;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Disable CoreAnimation actions so that the positions of the sublayers
    // immediately move to their new position.
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    [self configMaskLayer];
    [self configInterestRectLayer];
    [self configInterestRectAngleLayer];
    [self configTipTextLayer];

    [CATransaction commit];
}

- (void)configMaskLayer {
    CGRect rectOfInterest = self.scanCrop;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [path appendPath:[UIBezierPath bezierPathWithRect:rectOfInterest]];
    path.usesEvenOddFillRule = true;
    self.maskLayer.path = [path CGPath];

    const CGFloat *components = CGColorGetComponents(_configuration.maskFillColor.CGColor);
    CGFloat colorOfRed = components[0];
    CGFloat colorOfGreen = components[1];
    CGFloat colorOfBlue = components[2];
    CGFloat colorOfAlpa = components[3];
    UIColor *fillColor = [UIColor colorWithRed:colorOfRed green:colorOfGreen blue:colorOfBlue alpha:1.0];
    float opacity = colorOfAlpa;

    self.maskLayer.opacity = opacity;
    self.maskLayer.fillColor = fillColor.CGColor;
}

- (void)configInterestRectLayer {
    CGRect rectOfInterest = self.scanCrop;
    self.interestRectLayer.path = CGPathCreateWithRect(rectOfInterest, nil);
    self.interestRectLayer.lineWidth = _configuration.scanCropBorderWidth;
    self.interestRectLayer.strokeColor = _configuration.showScanCropBorder ? _configuration.scanCropBorderColor.CGColor : [UIColor clearColor].CGColor;
}

- (void)configInterestRectAngleLayer {
    CGRect rectOfInterest = self.scanCrop;

    UIColor *fillColor = _configuration.angleLineColor;
    CGFloat angleLineWidth = _configuration.angleLineWidth;
    CGFloat angleLineHeight = _configuration.angleLineHeight;
    CGFloat scanCropBorderWidth = _configuration.scanCropBorderWidth;

    UIBezierPath *anglePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, angleLineWidth, angleLineHeight)];
    [anglePath appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, angleLineHeight, angleLineWidth)]];

    self.topLeftAngleLayer.fillColor = fillColor.CGColor;
    self.topRightAngleLayer.fillColor = fillColor.CGColor;
    self.bottomLeftAngleLayer.fillColor = fillColor.CGColor;
    self.bottomRightAngleLayer.fillColor = fillColor.CGColor;

    CGFloat offset = 0;

    YFScanCropAngleAttachment angleAttachment = _configuration.angleAttachment;
    if (angleAttachment == YFScanCropAngleAttachmentOuter) {
        offset = -angleLineWidth + scanCropBorderWidth;
    } else if (angleAttachment == YFScanCropAngleAttachmentInner) {
        offset = -scanCropBorderWidth;
    } else if (angleAttachment == YFScanCropAngleAttachmentOn) {
        offset = (-angleLineWidth + scanCropBorderWidth) / 2;
    }

    self.topLeftAngleLayer.path = anglePath.CGPath;
    self.topLeftAngleLayer.position = CGPointMake(rectOfInterest.origin.x + offset, rectOfInterest.origin.y + offset);

    [anglePath applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
    self.topRightAngleLayer.path = anglePath.CGPath;
    self.topRightAngleLayer.position = CGPointMake(rectOfInterest.origin.x + CGRectGetWidth(rectOfInterest) - offset, rectOfInterest.origin.y + offset);

    [anglePath applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
    self.bottomRightAngleLayer.path = anglePath.CGPath;
    self.bottomRightAngleLayer.position = CGPointMake(rectOfInterest.origin.x + CGRectGetWidth(rectOfInterest) - offset, rectOfInterest.origin.y + CGRectGetHeight(rectOfInterest) - offset);

    [anglePath applyTransform:CGAffineTransformMakeRotation(M_PI_2)];
    self.bottomLeftAngleLayer.path = anglePath.CGPath;
    self.bottomLeftAngleLayer.position = CGPointMake(rectOfInterest.origin.x + offset, rectOfInterest.origin.y + CGRectGetHeight(rectOfInterest) - offset);
}

- (void)configTipTextLayer {
    NSString *tipText = self.configuration.tipText;
    if (!tipText || tipText.length == 0) {
        return;
    }
    CGRect rectOfInterest = self.scanCrop;
    CGSize textSize = [self calculateTitleSizeWithString:tipText];
    self.tipTextLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    self.tipTextLayer.string = tipText;

    self.tipTextLayer.position = CGPointMake(rectOfInterest.origin.x + CGRectGetWidth(rectOfInterest) / 2, rectOfInterest.origin.y + CGRectGetHeight(rectOfInterest) + textSize.height);
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return CGSizeZero;
    }
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:dic
                                       context:nil]
                      .size;
    return CGSizeMake(ceilf(size.width) + 2, size.height);
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

- (void)setConfiguration:(YFScanPreviewViewConfiguration *)configuration {
    if (_configuration != configuration) {
        _configuration = configuration ?: [YFScanPreviewViewConfiguration defaultConfiguration];

        [self setNeedsLayout];
    }
}

- (CGRect)getRectOfInterest {
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

    // ref:https://blog.cnbluebox.com/blog/2014/08/26/ioser-wei-ma-sao-miao/
    CGSize size = previewRect.size;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920. / 1080.; //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height) / 2;
        rectOfInterest = CGRectMake((scanCrop.origin.y + fixPadding) / fixHeight, scanCrop.origin.x / size.width, scanCrop.size.height / fixHeight, scanCrop.size.width / size.width);

    } else {
        CGFloat fixWidth = size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width) / 2;
        rectOfInterest = CGRectMake(scanCrop.origin.y / size.height, (scanCrop.origin.x + fixPadding) / fixWidth, scanCrop.size.height / size.height, scanCrop.size.width / fixWidth);
    }

    return rectOfInterest;
}

@end
