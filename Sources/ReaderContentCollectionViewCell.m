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
		
		self.contentView.backgroundColor = [UIColor redColor];
    }
    return self;
}


-(void)createContentView{
	
	self.pdfView = [[ReaderContentView alloc] initWithFrame:self.contentView.bounds fileURL:self.fileURL page:self.pageNumber password:self.passPhrase];

	[self.contentView addSubview:self.pdfView];
	NSLog(@"pageview  created for : %d", self.pageNumber);
		
}

-(void)prepareForReuse{
	
	[self.pdfView removeFromSuperview];
	self.pdfView = nil;
}

-(void)configureWithDocument:(NSURL *)inFileURL password:(NSString*)inPassword page:(NSInteger)inPageNumber{
	self.fileURL = inFileURL;
	self.passPhrase = inPassword;
	self.pageNumber = inPageNumber;
	
	[self createContentView];
	
}

@end
