//
//	ReaderMainToolbar.m
//	Reader v2.6.2
//
//	Created by Julius Oklamcak on 2011-07-01.
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
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"

#import <MessageUI/MessageUI.h>

@implementation ReaderMainToolbar
{
	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
}

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define PRINT_BUTTON_WIDTH 40.0f
#define EMAIL_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods


- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
	assert(object != nil); // Must have a valid ReaderDocument

	if ((self = [super initWithFrame:frame]))
	{
		
		[self setTranslucent:YES];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		NSMutableArray * tmpLeftButtonsArray = [NSMutableArray array];
		NSMutableArray * tmpRightButtonsArray = [NSMutableArray array];
		
#if (READER_STANDALONE == FALSE) // Option

		UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped:)];
		[tmpLeftButtonsArray addObject:doneButton];
#endif // end of READER_STANDALONE Option

#if (READER_ENABLE_THUMBS == TRUE) // Option

		UIBarButtonItem * thumbsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Thumbs"] style:UIBarButtonItemStylePlain target:self action:@selector(thumbsButtonTapped:)];
		[tmpLeftButtonsArray addObject:thumbsButton];
	

#endif // end of READER_ENABLE_THUMBS Option


#if (READER_BOOKMARKS == TRUE) // Option

		self.flagButton =  [UIButton buttonWithType:UIButtonTypeCustom];
		
		self.flagButton.frame = CGRectMake(0, 0, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[self.flagButton setImage:[UIImage imageNamed:@"Reader-Thumbs"] forState:UIControlStateNormal];
		[self.flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

		self.flagButton.autoresizingMask = UIViewAutoresizingNone;
		self.flagButton.exclusiveTouch = YES;
		
		UIBarButtonItem * tmpflagButton = [[UIBarButtonItem alloc] initWithCustomView:self.flagButton];
						   
						  

		[tmpRightButtonsArray addObject:tmpflagButton];
		
		markImageN = [UIImage imageNamed:@"Reader-Mark-N"]; // N image
		markImageY = [UIImage imageNamed:@"Reader-Mark-Y"];

#endif // end of READER_BOOKMARKS Option

#if (READER_ENABLE_MAIL == TRUE) // Option

		if ([MFMailComposeViewController canSendMail] == YES) // Can email
		{
			unsigned long long fileSize = [object.fileSize unsignedLongLongValue];

			if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
			{
				
				UIBarButtonItem * emailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Email"] style:UIBarButtonItemStylePlain target:self action:@selector(emailButtonTapped:)];
				[tmpRightButtonsArray addObject:emailButton];

			}
		}

#endif // end of READER_ENABLE_MAIL Option

#if (READER_ENABLE_PRINT == TRUE) // Option

		if (object.password == nil) // We can only print documents without passwords
		{
			Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

			if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
			{
				
				UIBarButtonItem * printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Reader-Print"] style:UIBarButtonItemStylePlain target:self action:@selector(printButtonTapped:)];
				[tmpRightButtonsArray addObject:printButton];
			}
		}

#endif // end of READER_ENABLE_PRINT Option
		UINavigationItem * tmpItem = nil;
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			
			tmpItem = [[UINavigationItem alloc] initWithTitle:[object.fileName stringByDeletingPathExtension]];
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

- (void)setBookmarkState:(BOOL)state
{
#if (READER_BOOKMARKS == TRUE) // Option


	UIImage *image = (state ? markImageY : markImageN);
	[self.flagButton setImage:image forState:UIControlStateNormal];
	self.flagButton.tag = (state)?1:0;
//	if (self.flagButton.enabled == NO)
//		markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#if (READER_BOOKMARKS == TRUE) // Option


	BOOL state = markButton.tag; // Bookmarked state
	UIImage *image = (state ? markImageY : markImageN);
	[self.flagButton setImage:image forState:UIControlStateNormal];


	if (self.flagButton.enabled == NO)
		self.flagButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self markButton:button];
}

@end
