//
//  ReaderContentCollectionViewCell.h
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import <UIKit/UIKit.h>
#import "ReaderContentView.h"
@interface ReaderContentCollectionViewCell : UICollectionViewCell

@property(strong) ReaderContentView * pdfView;

@property(strong) NSURL * fileURL;
@property(assign) NSInteger pageNumber;
@property(strong) NSString * passPhrase;

-(void)configureWithDocument:(NSURL *)inFileURL password:(NSString*)inPassword page:(NSInteger)inPageNumber;

@end
