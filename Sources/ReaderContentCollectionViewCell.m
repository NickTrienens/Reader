//
//  ReaderContentCollectionViewCell.m
//  Reader
//
//  Created by Nick Trienens on 10/18/13.
//
//

#import "ReaderContentCollectionViewCell.h"

@implementation ReaderContentCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)createContentView{
	
	self.pdfView = [[ReaderContentView alloc] initWithFrame:self.contentView.bounds fileURL:self.document.fileURL page:self.pageNumber password:self.document.password];

	[self.contentView addSubview:self.pdfView];
	[self.pdfView showPageThumb:self.document.fileURL page:self.pageNumber password:self.document.password guid:self.document.guid];

	//NSLog(@"pageview  created for : %d", self.pageNumber);
		
}

-(void)prepareForReuse{
	
	[self.pdfView removeFromSuperview];
	self.pdfView = nil;
	self.document  =nil;
}

-(void)dealloc{
	
	[self.pdfView removeFromSuperview];
	self.pdfView = nil;
	self.document = nil;
}

-(void)configureWithDocument:(ReaderDocument *)inDocument page:(NSInteger)inPageNumber{
	self.document = inDocument;
	self.pageNumber = inPageNumber;
	
	[self createContentView];
	
	
}

@end
