//
//  EdgeToEdgeCollectionViewLayout.m
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import "EdgeToEdgeCollectionViewLayout.h"

@implementation EdgeToEdgeCollectionViewLayout


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
	return YES;
}


- (CGSize)collectionViewContentSize{
	NSInteger tmpItemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
	return CGSizeMake(self.collectionView.bounds.size.width * tmpItemCount, self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
	NSMutableArray *tmpAttributeArray = [NSMutableArray array];
	
	for (NSInteger tmpIndex = rect.origin.x / self.collectionView.bounds.size.width; tmpIndex * self.collectionView.bounds.size.width < CGRectGetMaxX(rect); tmpIndex++){
		if (tmpIndex < 0)
			continue;
		
		id tmpAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:tmpIndex inSection:0]];
		[tmpAttributeArray addObject:tmpAttributes];
	}
	return tmpAttributeArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
	UICollectionViewLayoutAttributes *tmpAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	[tmpAttributes setFrame:CGRectMake(indexPath.row * self.collectionView.bounds.size.width, 0,self.collectionView.bounds.size.width, self.collectionView.bounds.size.height)];

	return tmpAttributes;
}


@end
