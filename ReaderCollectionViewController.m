//
//  ReaderCollectionViewController.m
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import "ReaderCollectionViewController.h"
#import "EdgeToEdgeCollectionViewLayout.h"

#import "ReaderPageBarCollectionView.h"


#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f




@interface ReaderCollectionViewController ()

@end

@implementation ReaderCollectionViewController

-(void)dealloc{
	
	mainToolbar  = nil;
	mainPagebar  = nil;
	self.document = nil;
}

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
	
	self.currentPage = [self.document.pageNumber integerValue];
	
	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
	
	CGRect viewRect = self.view.bounds; // View controller's view bounds
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			//viewRect.origin.y += STATUS_HEIGHT;
			//viewRect.size.height -= STATUS_HEIGHT;
		}
	}
	
	EdgeToEdgeCollectionViewLayout * tmpFlowLayout =  [[EdgeToEdgeCollectionViewLayout alloc] init];
	
	self.pdfPagesView = [[UICollectionView alloc] initWithFrame:viewRect collectionViewLayout:tmpFlowLayout];
	self.pdfPagesView.scrollsToTop = NO;
	self.pdfPagesView.pagingEnabled = YES;
	
	self.pdfPagesView.delaysContentTouches = NO;
	self.pdfPagesView.showsVerticalScrollIndicator = NO;
	self.pdfPagesView.showsHorizontalScrollIndicator = NO;
	self.pdfPagesView.contentMode = UIViewContentModeRedraw;
	self.pdfPagesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pdfPagesView.backgroundColor = [UIColor clearColor];
	self.pdfPagesView.userInteractionEnabled = YES;
	self.pdfPagesView.autoresizesSubviews = NO;
	self.pdfPagesView.dataSource = self;
	self.pdfPagesView.delegate = self;
	[self.pdfPagesView registerClass:[ReaderContentCollectionViewCell class] forCellWithReuseIdentifier:@"PDFView"];
	[self.view addSubview: self.pdfPagesView];
	
	viewRect = self.view.bounds; // View controller's view bounds\
	
	
	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
	{
		toolbarRect.size.height += STATUS_HEIGHT;
	}

	[self makeToolBarWithFrame:toolbarRect];
		
	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = 90;
	pagebarRect.origin.y = (viewRect.size.height - pagebarRect.size.height);
	
	[self makePageBarWithFrame:pagebarRect];
	
	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1;
	singleTapOne.numberOfTapsRequired = 1;
	singleTapOne.delegate = self;
	[self.pdfPagesView addGestureRecognizer:singleTapOne];
	
	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1;
	doubleTapOne.numberOfTapsRequired = 2;
	doubleTapOne.delegate = self;
	[self.pdfPagesView addGestureRecognizer:doubleTapOne];
	
	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2;
	doubleTapTwo.numberOfTapsRequired = 2;
	doubleTapTwo.delegate = self;
	[self.pdfPagesView addGestureRecognizer:doubleTapTwo];
	
	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail


}

-(void)makeToolBarWithFrame:(CGRect)inFrame{
	
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:inFrame document:self.document]; // At top
	mainToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	mainToolbar.delegate = self;
	[self.view addSubview:mainToolbar];

}

-(void)makePageBarWithFrame:(CGRect)inFrame{
	
	mainPagebar = [[ReaderPageBarCollectionView alloc] initWithFrame:inFrame document:self.document]; // At bottom
	mainPagebar.delegate = self;
	[self.view addSubview:mainPagebar];

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
    NSLog(@"rotated: %@", NSStringFromCGRect(self.pdfPagesView.frame));
//	[self.pdfPagesView.collectionViewLayout invalidateLayout];
//	[self.pdfPagesView reloadData];
//	[mainPagebar.pdfPagesView.collectionViewLayout invalidateLayout];
	

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
//		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{

	
	
}



- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
	
	[super didReceiveMemoryWarning];
}


-(void)showDocumentPage:(NSInteger)page
{
	page = MAX(1, page);
	page = MIN([self.document.pageCount intValue], page);
	
	self.currentPage = page;
	self.document.pageNumber = @(page);
	
	[self.pdfPagesView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

	[mainPagebar updatePagebar]; // Update the pagebar display


	
}
#pragma mark UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[self calculateCurrentPage];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if(scrollView.tracking){
		self.throttler ++ ;
		if(self.throttler%2 ==0  || true ){
			[self calculateCurrentPage];
			self.throttler = 0;
		}
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
	[self calculateCurrentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	
	self.throttler = 0;
	[self calculateCurrentPage];
	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	self.throttler = 0;
	[self calculateCurrentPage];
}


-(void)calculateCurrentPage{
	
	ReaderContentCollectionViewCell *targetView = nil;
	CGRect tmpViewFrame	= self.pdfPagesView.frame;
	for (ReaderContentCollectionViewCell * tmpView in [self.pdfPagesView visibleCells]) {
		if(targetView == nil){
			targetView = tmpView;
		}
		CGRect tmpFrame = [self.view convertRect:tmpView.frame fromView:self.pdfPagesView];
		if( CGRectGetMidX(tmpFrame) < CGRectGetMaxX(tmpViewFrame) && CGRectGetMidX(tmpFrame) > CGRectGetMinX(self.view.frame)){
			targetView = tmpView;
			break;

		}
	}
	
	int tmpPage = (self.pdfPagesView.contentOffset.x / tmpViewFrame.size.width)+1;
	
	if(targetView != nil && targetView.pageNumber != self.currentPage){
		self.currentPage = tmpPage;//targetView.pageNumber;
		self.document.pageNumber = @(self.currentPage);
		
		[mainPagebar updatePagebar]; // Update the pagebar display
		[self updateToolbarBookmarkIcon];
	}

}


#pragma mark UICollection Data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	
	NSInteger count = [self.document.pageCount integerValue];
	return count;
	
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	ReaderContentCollectionViewCell *cell = (ReaderContentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PDFView" forIndexPath:indexPath];
		
	[cell configureWithDocument:self.document page:indexPath.item+1];
	
	return cell;
	
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UICollectionView class]] || [touch.view isDescendantOfView:self.pdfPagesView]){
		return YES;
	}

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber {
	
	NSInteger maxPage = [self.document.pageCount integerValue];
	NSInteger minPage = 1; // Minimum
	
	if ((maxPage > minPage) && (self.currentPage != minPage))
	{
		[self showDocumentPage:self.currentPage-1];
	}

}

- (void)incrementPageNumber {
	
	NSInteger maxPage = [self.document.pageCount integerValue];
	NSInteger minPage = 1; // Minimum
	
	if ((maxPage > minPage) && (self.currentPage != maxPage))
	{
		[self showDocumentPage:self.currentPage+1];
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
						
						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
			
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
					{
						[mainToolbar showToolbar];
						[mainPagebar showPagebar]; // Show
						
						if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && self.adjustStatusBar) {
							[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
						}
					}else{
						[mainToolbar hideToolbar];
						[mainPagebar hidePagebar]; // Hide
						if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && self.adjustStatusBar) {
							[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
			[self incrementPageNumber];
			return;
		}
		
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
		
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber];
			return;
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
					[targetView zoomIncrement];
					break;
				}
					
				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement];
					break;
				}
			}
			
			return;
		}
		
		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
		
		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber];
			return;
		}
		
		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;
		
		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber];
			return;
		}
	}
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info
			
			CGPoint point = [touch locationInView:self.view]; // Touch location
			
			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
			
			if (CGRectContainsPoint(areaRect, point) == false) return;
		}
		
		[mainToolbar hideToolbar];
		[mainPagebar hidePagebar]; // Hide
		
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


- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
#if (READER_ENABLE_PRINT == TRUE) // Option
	
	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");
	
	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL
		
		printInteraction = [printInteractionController sharedPrintController];
		
		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];
			
			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;
			
			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;
			
			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
				 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
				 {
#ifdef DEBUG
					 if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
				 }
				 ];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
				 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
				 {
#ifdef DEBUG
					 if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
				 }
				 ];
			}
		}
	}
	
#endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
#if (READER_ENABLE_MAIL == TRUE) // Option
	
	if ([MFMailComposeViewController canSendMail] == NO) return;
	
	
	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
	
	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document
		
		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
		
		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
			
			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
			
			[mailComposer setSubject:fileName]; // Use the document file name for the subject
			
			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
			
			mailComposer.mailComposeDelegate = self; // Set the delegate
			
			[self presentViewController:mailComposer animated:YES completion:NULL];
		}
	}
	
#endif // end of READER_ENABLE_MAIL Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
	
	NSInteger page = [self.document.pageNumber integerValue];
	
	if ([self.document.bookmarks containsIndex:page]) // Remove bookmark
	{
		[mainToolbar setBookmarkState:NO];
		[self.document.bookmarks removeIndex:page];
	}
	else // Add the bookmarked page index to the bookmarks set
	{
		[mainToolbar setBookmarkState:YES];
		[self.document.bookmarks addIndex:page];
	}
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
	
	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon
	
	[self dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}

- (void)updateToolbarBookmarkIcon
{
	NSInteger page = [self.document.pageNumber integerValue];
	
	BOOL bookmarked = [self.document.bookmarks containsIndex:page];
	
	[mainToolbar setBookmarkState:bookmarked]; // Update
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
}



@end
