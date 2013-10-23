//
//  ReaderCollectionViewController.m
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import "ReaderCollectionViewController.h"
#import "EdgeToEdgeCollectionViewLayout.h"



#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f




@interface ReaderCollectionViewController ()

@end

@implementation ReaderCollectionViewController



- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id reader = nil; // ReaderViewController object
	
	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
		
			[object updateProperties];
			self.document = object; // Retain the supplied ReaderDocument object for our use
			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
			
			reader = self; // Return an initialized ReaderViewController object
		}
	}
	
	return reader;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	assert(self.document != nil); // Must have a valid ReaderDocument
	
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	CGRect viewRect = self.view.bounds; // View controller's view bounds
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			viewRect.origin.y += STATUS_HEIGHT;
		}
	}
	
	
	EdgeToEdgeCollectionViewLayout * tmpFlowLayout =  [[EdgeToEdgeCollectionViewLayout alloc] init];
//	tmpFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//	tmpFlowLayout.minimumInteritemSpacing =0;
//	tmpFlowLayout.sectionInset = UIEdgeInsetsZero;
	
	self.pdfPagesView = [[UICollectionView alloc] initWithFrame:viewRect collectionViewLayout:tmpFlowLayout];
	self.pdfPagesView.scrollsToTop = NO;
	self.pdfPagesView.pagingEnabled = YES;
	
	self.pdfPagesView.delaysContentTouches = NO;
	self.pdfPagesView.showsVerticalScrollIndicator = NO;
	self.pdfPagesView.showsHorizontalScrollIndicator = NO;
	self.pdfPagesView.contentMode = UIViewContentModeRedraw;
	self.pdfPagesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pdfPagesView.backgroundColor = [UIColor orangeColor];
	self.pdfPagesView.userInteractionEnabled = YES;
	self.pdfPagesView.autoresizesSubviews = NO;
	
//	tmpFlowLayout.itemSize = self.pdfPagesView.frame.size;
	
	self.pdfPagesView.dataSource = self;
	[self.pdfPagesView registerClass:[ReaderContentCollectionViewCell class] forCellWithReuseIdentifier:@"PDFView"];
	
	[self.view addSubview: self.pdfPagesView];
	
	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
	
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:self.document]; // At top
	
	mainToolbar.delegate = self;
	
	[self.view addSubview:mainToolbar];
	
	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);
	
	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:self.document]; // At bottom
	
	mainPagebar.delegate = self;
	
	[self.view addSubview:mainPagebar];
	
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1;
	singleTapOne.numberOfTapsRequired = 1;
	singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];
	
	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1;
	doubleTapOne.numberOfTapsRequired = 2;
	doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];
	
	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2;
	doubleTapTwo.numberOfTapsRequired = 2;
	doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];
	
	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail


}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


-(void)viewWillAppear:(BOOL)animated{
	
	//[(UICollectionViewFlowLayout*)self.pdfPagesView.collectionViewLayout setItemSize: CGRectInset(self.pdfPagesView.bounds,5,0).size]; // Update content views

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"rotated");
//	[(UICollectionViewFlowLayout*)self.pdfPagesView.collectionViewLayout setItemSize:CGRectInset(self.pdfPagesView.bounds,5,0).size]; // Update content views

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
	
//	[(UICollectionViewFlowLayout*)self.pdfPagesView.collectionViewLayout setItemSize: self.pdfPagesView.bounds.size]; // Update content views
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
//		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
	
	//[(UICollectionViewFlowLayout*)self.pdfPagesView.collectionViewLayout setItemSize: self.pdfPagesView.bounds.size]; // Update content views
	
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
 - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
 {
 //if (isVisible == NO) return; // iOS present modal bodge
 
 //if (fromInterfaceOrientation == self.interfaceOrientation) return;
 }
 */

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	
	[super didReceiveMemoryWarning];
}




#pragma mark UICollection Data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	
	NSInteger count = [self.document.pageCount integerValue];
	return count;
	
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	ReaderContentCollectionViewCell *cell = (ReaderContentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PDFView" forIndexPath:indexPath];
		
	[cell configureWithDocument:self.document.fileURL password:self.document.password page:indexPath.item+1];
	
	return cell;
	
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UICollectionView class]]) return YES;
	
	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (self.pdfPagesView.tag == 0) // Scroll view did end
	{
		NSInteger page = [self.document.pageNumber integerValue];
		NSInteger maxPage = [self.document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
		
		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = self.pdfPagesView.contentOffset;
			
			contentOffset.x -= self.pdfPagesView.bounds.size.width; // -= 1
			
			[self.pdfPagesView setContentOffset:contentOffset animated:YES];
			
			self.pdfPagesView.tag = (page - 1); // Decrement page number
		}
	}
}

- (void)incrementPageNumber
{
	if (self.pdfPagesView.tag == 0) // Scroll view did end
	{
		NSInteger page = [self.document.pageNumber integerValue];
		NSInteger maxPage = [self.document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
		
		if ((maxPage > minPage) && (page != maxPage))
		{
			CGPoint contentOffset = self.pdfPagesView.contentOffset;
			
			contentOffset.x += self.pdfPagesView.bounds.size.width; // += 1
			
			[self.pdfPagesView setContentOffset:contentOffset animated:YES];
			
			self.pdfPagesView.tag = (page + 1); // Increment page number
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
		
		CGPoint point = [recognizer locationInView:recognizer.view];
		
		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area
		
		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
//			NSInteger page = [document.pageNumber integerValue]; // Current page #
//			
//			NSNumber *key = [NSNumber numberWithInteger:page]; // Page number key
//			
//			ReaderContentView *targetView = [contentViews objectForKey:key];
			ReaderContentView *targetView = [(ReaderContentCollectionViewCell*)[self.pdfPagesView visibleCells][0] pdfView];

			
			id target = [targetView processSingleTap:recognizer]; // Target
			
			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object
					
					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string
						
						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];
							
							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}
					
					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
#ifdef DEBUG
						NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
					}
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger value = [target integerValue]; // Number
						
						//[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}
			
			return;
		}
		
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
		
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
		
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
		
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds
		
		CGPoint point = [recognizer locationInView:recognizer.view];
		
		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);
		
		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			ReaderContentView *targetView = [(ReaderContentCollectionViewCell*)[self.pdfPagesView visibleCells][0] pdfView];
			
			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}
					
				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}
			
			return;
		}
		
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
		
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}
		
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
		
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option
	
	[self.document saveReaderDocument]; // Save any ReaderDocument object changes
	
	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:self.document.guid];
	
	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
		
	if ([self.delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[self.delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}
	
#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
	
	
	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:self.document];
	
	thumbsViewController.delegate = self; thumbsViewController.title = self.title;
	
	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	
	[self presentViewController:thumbsViewController animated:NO completion:NULL];
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self.pdfPagesView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}



@end
