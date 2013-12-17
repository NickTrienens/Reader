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
#import "ReaderMainPagebar.h"

@class ReaderPageBarCollectionView;

@protocol ReaderMainPagebarCollectionDelegate <ReaderMainPagebarDelegate>

@required
@end


@interface ReaderPageBarCollectionView : UIView<UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegate, ReaderPagebarControls>

@property(strong) UICollectionView * pdfPagesView;
@property(strong) ReaderDocument *document;

@property (nonatomic, weak, readwrite) id <ReaderMainPagebarDelegate> delegate;

@property(strong) UINavigationBar * backgroundView;


@property(strong) NSTimer *enableTimer;
@property(strong) NSTimer *trackTimer;


- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object;



@end
