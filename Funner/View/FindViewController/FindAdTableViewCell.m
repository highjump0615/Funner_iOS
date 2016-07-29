//
//  FindAdTableViewCell.m
//  Funner
//
//  Created by highjump on 14-11-22.
//
//

#import "FindAdTableViewCell.h"

@interface FindAdTableViewCell() {
    NSTimer*	m_timer;
}

@end

@implementation FindAdTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initView {
    NSInteger nWidth = self.mButAd1.frame.size.width;
    [self.mScrollView setContentSize:CGSizeMake(nWidth * 3, 0)];
    
    if (!m_timer)
        m_timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(onAdTimer) userInfo:nil repeats:YES];
}

- (void)onAdTimer
{
    CGPoint pt = [self.mScrollView contentOffset];
    
    pt.x += self.mScrollView.frame.size.width;
    if (pt.x >= self.mScrollView.frame.size.width * self.mPageControl.numberOfPages)
        pt.x = 0;
    
    [self.mScrollView setContentOffset:pt animated:YES];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.mScrollView.frame.size.width;
    NSInteger nPage = (NSInteger)floor((self.mScrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.mPageControl.currentPage = nPage;
}

@end
