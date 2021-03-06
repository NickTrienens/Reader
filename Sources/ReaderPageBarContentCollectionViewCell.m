//
//  ReaderPageBarContentCollectionViewCell.m
//  Reader
//
//  Created by Nick Trienens on 11/25/13.
//
//

#import "ReaderPageBarContentCollectionViewCell.h"
#import "ReaderThumbRequest.h"
#import "ReaderThumbCache.h"

@implementation ReaderPageBarContentCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)configureWithDocument:(ReaderDocument *)inDocument page:(NSInteger)inPageNumber{
	self.document = inDocument;
	self.pageNumber = inPageNumber;
	
	[self createContentView];
	
	
}

-(void)setSelected:(BOOL)selected{
	if(selected){
		self.pdfView.layer.borderColor = [UIColor grayColor].CGColor;
		self.pdfView.layer.borderWidth = 1;
	}else{
		self.pdfView.layer.borderColor = [UIColor grayColor].CGColor;
		self.pdfView.layer.borderWidth = 0;
	}
}

-(void)createContentView{
	
	
	CGSize size = self.contentView.bounds.size;
	
	NSURL *fileURL = self.document.fileURL;
	NSString *guid = self.document.guid;
	NSString *phrase = self.document.password;
	
	self.pdfView = [[ReaderPagebarThumb alloc] initWithFrame:self.contentView.bounds small:YES]; // Create a small thumb view
	[self.contentView addSubview:self.pdfView];
	
	ReaderThumbRequest *thumbRequest = [ReaderThumbRequest newForView:self.pdfView fileURL:fileURL password:phrase guid:guid page:self.pageNumber size:size];
	
	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:NO]; // Request the thumb
	if ([image isKindOfClass:[UIImage class]]) [self.pdfView showImage:image]; // Use thumb image from cache
	
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



@end