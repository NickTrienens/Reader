//
//  ReaderPageBarContentCollectionViewCell.h
//  Reader
//
//  Created by Nick Trienens on 11/25/13.
//
//

#import <UIKit/UIKit.h>
#import "ReaderMainPagebar.h"
#import "ReaderDocument.h"


@interface ReaderPageBarContentCollectionViewCell : UICollectionViewCell

@property(strong) ReaderThumbView * pdfView;


@property(strong) ReaderDocument * document;
@property(assign) NSInteger pageNumber;


-(void)configureWithDocument:(ReaderDocument *)inDocument page:(NSInteger)inPageNumber;


@end
