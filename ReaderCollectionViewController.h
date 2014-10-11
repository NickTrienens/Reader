//
//  ReaderCollectionViewController.h
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import <UIKit/UIKit.h>

#import "ReaderDocument.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import <MessageUI/MessageUI.h>

#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import "ReaderContentCollectionViewCell.h"
#import "ReaderPageBarCollectionView.h"

@class ReaderCollectionViewController;

@protocol ReaderCollectionViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(ReaderCollectionViewController *)viewController;

@end



@interface ReaderCollectionViewController : UIViewController<UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate, UIToolbarDelegate, UINavigationBarDelegate>
{
	
	
	
	ReaderPageBarCollectionView *mainPagebar;
	

}
@property(strong) ReaderMainToolbar *mainToolbar;
@property(assign) NSInteger currentPage;
@property(assign) NSInteger throttler;
@property(strong) ReaderDocument *document;
@property (nonatomic, weak, readwrite) id <ReaderCollectionViewControllerDelegate> delegate;
- (id)initWithReaderDocument:(ReaderDocument *)object;
@property(assign) BOOL adjustStatusBar;
@property(strong) UICollectionView * pdfPagesView;


-(void)showDocumentPage:(NSInteger)page;
- (void)decrementPageNumber;
- (void)incrementPageNumber;
- (void)calculateCurrentPage;

//-(ReaderMainToolbar*)mainToolbar;

@end
