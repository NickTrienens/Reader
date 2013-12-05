//
//  ReaderPageBarCollectionView.m
//  Reader
//
//  Created by Nick Trienens on 11/25/13.
//
//

#import "ReaderPageBarCollectionView.h"
#import "ReaderPageBarContentCollectionViewCell.h"


@implementation ReaderPageBarCollectionView

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
	assert(object != nil); // Must have a valid ReaderDocument
	
	if ((self = [self initWithFrame:frame]))
	{
		self.document = object;
		[self.pdfPagesView reloadData];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		
		self.backgroundView = [[UINavigationBar alloc] initWithFrame:self.bounds];
		[self.backgroundView setTranslucent:YES];
		self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:self.backgroundView];
		
		UICollectionViewFlowLayout * tmpFlowLayout =  [[UICollectionViewFlowLayout alloc] init];
		tmpFlowLayout.itemSize = CGRectInset(self.bounds, 304, 4).size;
		
		tmpFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
		self.pdfPagesView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:tmpFlowLayout];
		self.pdfPagesView.scrollsToTop = NO;
		self.pdfPagesView.pagingEnabled = NO;
		self.pdfPagesView.delaysContentTouches = NO;
		self.pdfPagesView.showsVerticalScrollIndicator = NO;
		self.pdfPagesView.showsHorizontalScrollIndicator = NO;
//		self.pdfPagesView.contentMode = UIViewContentModeRedraw;
		self.pdfPagesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.pdfPagesView.backgroundColor = [UIColor clearColor];
//		self.pdfPagesView.userInteractionEnabled = YES;
		self.pdfPagesView.autoresizesSubviews = NO;
		self.pdfPagesView.dataSource = self;
		self.pdfPagesView.delegate = self;
		[self.pdfPagesView registerClass:[ReaderPageBarContentCollectionViewCell class] forCellWithReuseIdentifier:@"PDFMiniView"];
		[self addSubview: self.pdfPagesView];
		

    }
    return self;
}


#pragma mark UICollection Data source
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
	
	CGSize tmpPageSize = [self.document getPageSize:indexPath.item+1 forHeight:80];
	
	return tmpPageSize;
	
	
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	
	NSInteger count = [self.document.pageCount integerValue];
	return count;
	
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	ReaderPageBarContentCollectionViewCell *cell = (ReaderPageBarContentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PDFMiniView" forIndexPath:indexPath];
	
	

	[cell configureWithDocument:self.document page:indexPath.item+1];
	
	return cell;
	
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	
	if(self.delegate){
		[self.delegate pagebar:self gotoPage:indexPath.item+1];
		
	}
	
}


- (void)updatePagebarViews
{
	NSInteger page = [self.document.pageNumber integerValue]; // #
	[self.pdfPagesView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:page-1 inSection:0]];

}

#pragma mark Public Methods

- (void)updatePagebar
{
	if (self.hidden == NO) // Only if visible
	{
		[self updatePagebarViews]; // Update views
	}
}

- (void)hidePagebar
{
	if (self.hidden == NO) // Only if visible
	{
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^(void){
			 self.alpha = 0.0f;
		 } completion:^(BOOL finished){
			 self.hidden = YES;
		 }];
	}
}

- (void)showPagebar
{
	if (self.hidden == YES) // Only if hidden
	{
		[self updatePagebarViews]; // Update views first
		
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^(void){
			 self.hidden = NO;
			 self.alpha = 1.0f;
		 } completion:NULL];
	}
}
@end
