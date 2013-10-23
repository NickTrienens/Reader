//
//  EdgeToEdgeCollectionViewLayout.m
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import "EdgeToEdgeCollectionViewLayout.h"

@implementation EdgeToEdgeCollectionViewLayout


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

- (void)prepareLayout
{
	if ([self.collectionView isKindOfClass:[UICollectionView class]])
	{
		UICollectionView *tmpViewPager = (UICollectionView *)self.collectionView;
//		if ([tmpViewPager.pagerDataSource respondsToSelector:@selector(headerSizeForViewPager:)])
//			self.headerSize = [tmpViewPager.pagerDataSource headerSizeForViewPager:tmpViewPager];
//		if ([tmpViewPager.pagerDataSource respondsToSelector:@selector(headerOffsetForViewPager:)])
//			self.headerOffset = [tmpViewPager.pagerDataSource headerOffsetForViewPager:tmpViewPager];
//		if ([tmpViewPager.pagerDataSource respondsToSelector:@selector(footerSizeForViewPager:)])
//			self.footerSize = [tmpViewPager.pagerDataSource footerSizeForViewPager:tmpViewPager];
//		if ([tmpViewPager.pagerDataSource respondsToSelector:@selector(footerOffsetForViewPager:)])
//			self.footerOffset = [tmpViewPager.pagerDataSource footerOffsetForViewPager:tmpViewPager];
	}
}

- (CGSize)collectionViewContentSize
{
	NSInteger tmpItemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
	return CGSizeMake(self.collectionView.bounds.size.width * tmpItemCount, self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray *tmpAttributeArray = [NSMutableArray array];
	
	// Determine visible indexPaths
	for (NSInteger tmpIndex = rect.origin.x / self.collectionView.bounds.size.width; tmpIndex * self.collectionView.bounds.size.width < CGRectGetMaxX(rect); tmpIndex++)
	{
		if (tmpIndex < 0)
			continue;
		
		id tmpAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:tmpIndex inSection:0]];
		[tmpAttributeArray addObject:tmpAttributes];
	}
	
//	if (self.headerSize > 0)
//	{
//		id tmpAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//		[tmpAttributeArray addObject:tmpAttributes];
//	}
//	if (self.footerSize > 0)
//	{
//		id tmpAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
//		[tmpAttributeArray addObject:tmpAttributes];
//	}

	return tmpAttributeArray;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//	if ([kind isEqualToString:UICollectionElementKindSectionHeader])
//	{
//		CGPoint tmpContentOffset = self.collectionView.contentOffset;
//		
//		UICollectionViewLayoutAttributes *tmpAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
//		[tmpAttributes setFrame:CGRectMake(tmpContentOffset.x, 0, self.collectionView.bounds.size.width, self.headerSize)];
//		[tmpAttributes setZIndex:1024];
//		
//		return tmpAttributes;
//	}
//	else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
//	{
//		CGPoint tmpContentOffset = self.collectionView.contentOffset;
//		
//		UICollectionViewLayoutAttributes *tmpAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
//		[tmpAttributes setFrame:CGRectMake(tmpContentOffset.x, self.collectionView.bounds.size.height - self.footerSize, self.collectionView.bounds.size.width, self.footerSize)];
//		[tmpAttributes setZIndex:1024];
//		
//		return tmpAttributes;
//	}
//	return nil;
//}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *tmpAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	[tmpAttributes setFrame:CGRectMake(indexPath.row * self.collectionView.bounds.size.width,
									   0,
									   self.collectionView.bounds.size.width,
									   self.collectionView.bounds.size.height)];
	return tmpAttributes;
}


@end
