//
//	ThumbsMainToolbar.m
//	Reader v2.6.2
//
//	Created by Julius Oklamcak on 2011-09-01.
//	Copyright © 2011-2013 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"

@implementation ThumbsMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define SHOW_CONTROL_WIDTH 78.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ThumbsMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame title:nil];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
	if ((self = [super initWithFrame:frame]))
	{
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.translucent = YES;
		
		NSMutableArray * tmpLeftButtonsArray = [NSMutableArray array];
		NSMutableArray * tmpRightButtonsArray = [NSMutableArray array];

		UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
		[tmpLeftButtonsArray addObject:doneButton];
		

#if (READER_BOOKMARKS == TRUE) // Option


		UIImage *thumbsImage = [UIImage imageNamed:@"Reader-Thumbs"];
		UIImage *bookmarkImage = [UIImage imageNamed:@"Reader-Mark-Y"];
		NSArray *buttonItems = [NSArray arrayWithObjects:thumbsImage, bookmarkImage, nil];

		UISegmentedControl *showControl = [[UISegmentedControl alloc] initWithItems:buttonItems];

		showControl.frame = CGRectMake(0 , 0 , SHOW_CONTROL_WIDTH, BUTTON_HEIGHT);
		showControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		showControl.segmentedControlStyle = UISegmentedControlStyleBar;
		showControl.selectedSegmentIndex = 0; // Default segment index
		showControl.exclusiveTouch = YES;

		[showControl addTarget:self action:@selector(showControlTapped:) forControlEvents:UIControlEventValueChanged];
		
		UIBarButtonItem * thumbsButton = [[UIBarButtonItem alloc] initWithCustomView:showControl];
		[tmpRightButtonsArray addObject:thumbsButton];


#endif // end of READER_BOOKMARKS Option
										  UINavigationItem * tmpItem = nil;
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			
			tmpItem = [[UINavigationItem alloc] initWithTitle:title];
			self.items = @[tmpItem];
			tmpItem.leftBarButtonItems = tmpLeftButtonsArray;
			tmpItem.rightBarButtonItems = tmpRightButtonsArray;
			
		}
		if(tmpItem == nil){
			
			tmpItem = [[UINavigationItem alloc] init];
			tmpItem.leftBarButtonItems = tmpLeftButtonsArray;
			tmpItem.rightBarButtonItems = tmpRightButtonsArray;
			self.items = @[tmpItem];
			
		}

	}

	return self;
}

#pragma mark UISegmentedControl action methods

- (void)showControlTapped:(UISegmentedControl *)control
{
	[delegate tappedInToolbar:self showControl:control];
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

@end
