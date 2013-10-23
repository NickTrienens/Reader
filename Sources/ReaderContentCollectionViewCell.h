//
//  ReaderContentCollectionViewCell.h
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import <UIKit/UIKit.h>
#import "ReaderContentView.h"
#import "ReaderDocument.h"


@interface ReaderContentCollectionViewCell : UICollectionViewCell

@property(strong) ReaderContentView * pdfView;

@property(strong) ReaderDocument * document;
@property(assign) NSInteger pageNumber;

-(void)configureWithDocument:(ReaderDocument *)inDocument page:(NSInteger)inPageNumber;

@end
