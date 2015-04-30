//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>

// Action Sheet constants

#define kActionSheetBounce         10

#define kActionSheetBorder         _size_S(32)
#define kActionSheetInset         _size_S(29)

#define kActionSheetButtonHeight   _size_S(55)
#define kActionSheetTopMargin      _size_S(32)

#define kActionSheetCorner         _size_S(8)

/**
 * A simple block-enabled API wrapper on top of UIActionSheet.
 */
@interface BlockActionSheet : NSObject {
@private
    UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
}

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;

+ (id)sheetWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title;

- (void)setCancelButtonWithTitle:(NSString *) title block:(void (^)()) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title block:(void (^)()) block;
- (void)addButtonWithTitle:(NSString *) title block:(void (^)()) block;

- (void)setCancelButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;
- (void)addButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(void (^)()) block;

- (void)showInView:(UIView *)view completion:(void (^)(BOOL finished))completion;
- (NSUInteger)buttonCount;

@end
