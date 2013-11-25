//
//  ReaderPageBarCollectionView.h
//  Reader
//
//  Created by Nick Trienens on 11/25/13.
//
//

#import <UIKit/UIKit.h>
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"


@class ReaderPageBarCollectionView;

@protocol ReaderMainPagebarDelegate <NSObject>

@required // Delegate protocols

- (void)pagebar:(ReaderPageBarCollectionView *)pagebar gotoPage:(NSInteger)page;

@end


@interface ReaderPageBarCollectionView : UIView<UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate>

@property(strong) UICollectionView * pdfPagesView;
@property(strong) ReaderDocument *document;

@property (nonatomic, weak, readwrite) id <ReaderMainPagebarDelegate> delegate;

@property(strong) UINavigationBar * backgroundView;


@property(strong) NSTimer *enableTimer;
@property(strong) NSTimer *trackTimer;


- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object;

- (void)updatePagebar;

- (void)hidePagebar;
- (void)showPagebar;

@end
