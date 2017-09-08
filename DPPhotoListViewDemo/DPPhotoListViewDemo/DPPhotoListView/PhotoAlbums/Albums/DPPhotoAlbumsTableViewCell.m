//
//  DPPhotoAlbumsTableViewCell.m
//  DPPhotoListViewDemo
//
//  Created by Andrew on 2017/9/4.
//  Copyright © 2017年 Andrew. All rights reserved.
//

#import "DPPhotoAlbumsTableViewCell.h"
#import "DPPhotoLibrary.h"

@implementation DPPhotoAlbumsTableViewCell
{
    UILabel *thumbnailLabel;
    UIImageView *thumbnailImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews
{
    thumbnailImageView = [[UIImageView alloc]init];
    thumbnailImageView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:thumbnailImageView];
    
    thumbnailLabel = [[UILabel alloc]init];
    thumbnailLabel.textAlignment = NSTextAlignmentLeft;
    thumbnailLabel.font = PUB_FONT;
    thumbnailLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:thumbnailLabel];
    
#if __has_include(<Masonry/Masonry.h>)
    [thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(PUB_MARGIN);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(2);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(- 2);
        make.width.mas_equalTo(self.contentView.mas_height).with.offset(- 4);
    }];
    
    [thumbnailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(thumbnailImageView.mas_right).with.offset(PUB_MARGIN);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(- PUB_MARGIN);
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
#else
    thumbnailImageView.frame = CGRectMake(PUB_MARGIN, 2, ChooseListView_Cell_Height - 4, ChooseListView_Cell_Height - 4);
    thumbnailLabel.frame = CGRectMake(ChooseListView_Cell_Height + PUB_MARGIN, 0, SCREEN_WIDTH - 2 * PUB_MARGIN - ChooseListView_Cell_Height, ChooseListView_Cell_Height);
#endif
    
}

- (void)setModel:(DPPhotoAlbumModel *)model
{
    [DPPhotoUtils requestOriginalImageDataForAsset:model.headImageAsset completion:^(NSData *data, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            thumbnailImageView.image = [UIImage imageWithData:data];
        });
    }];
    thumbnailLabel.text = [model.title stringByAppendingString:[NSString stringWithFormat:@" (%ld)",model.count]];
}

@end
