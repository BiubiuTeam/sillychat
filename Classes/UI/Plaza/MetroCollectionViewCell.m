//
//  MetroCollectionViewCell.m
//  sillyChat
//
//  Created by haowenliang on 15/4/22.
//  Copyright (c) 2015年 dpsoft. All rights reserved.
//

#import "MetroCollectionViewCell.h"
#import "SillyBroacastModel.h"
#import "TagBaseView.h"
#import "TagTextView.h"
#import "TagImageView.h"
#import "TagVoiceView.h"

@implementation MetroCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateMetroWithData:(SillyBroacastModel*)datasource
{
    TagBaseView* base = (TagBaseView*)[self findSubview:@"TagBaseView" resursion:YES];
    [base removeFromSuperview];
    base = [MetroCollectionViewCell tagViewOfBroacastModel:datasource];
    [self addSubview:base];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    TagBaseView* base = (TagBaseView*)[self findSubview:@"TagBaseView" resursion:YES];
    base.frame = self.bounds;
}

#pragma mark - class methods

+ (TagBaseView*)tagViewOfBroacastModel:(SillyBroacastModel*)broacast
{
    if (broacast == nil) return nil;
    
    BroacastType type = [broacast.titleType unsignedIntegerValue];
    TagBaseView* tagView = nil;
    switch (type) {
        case BroacastType_Image:{
            tagView = [[TagImageView alloc] initWithFrame:CGRectZero viewType:type];
            [(TagImageView*)tagView setImageContent:broacast.titleCont];
            
            [tagView setViewContent:[broacast.extension objectForKey:@"text"]];
        }break;
        case BroacastType_Voice:{
            tagView = [[TagVoiceView alloc] initWithFrame:CGRectZero viewType:type];
            [tagView setViewContent:[broacast.extension objectForKey:@"duration"]];
        }break;
        case BroacastType_Text:
        default:{
            tagView = [[TagTextView alloc] initWithFrame:CGRectZero viewType:type];
            [tagView setViewContent:broacast.titleCont];
        }break;
    }
    
    tagView.datasource = broacast;
    return tagView;
}

@end
