//
//	Copyright (c) 2008-2009, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppReviews nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ARAppStoreApplicationTableCell.h"
#import "ARAppStoreApplication.h"
#import "ARAppIconDownloadOperation.h"
#import "PSLog.h"


@implementation ARAppStoreApplicationTableCell

@synthesize app;

- (id)initWithApplication:(ARAppStoreApplication *)anApp
					reuseIdentifier:(NSString *)reuseIdentifier
{	
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle
									reuseIdentifier:reuseIdentifier])
	{
		app = [anApp retain];
	}
	
	return self;
}

- (void)dealloc
{
	[app release];
	
	[super dealloc];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	
	[app cancelIconDownload];
}

- (void)tableView:(UITableView *)tableView
willDisplayCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (app.appIcon || !app.appIconURL) {
		// TODO: set a placeholder image when there is no URL
		return;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(appIconDownloaded:)
																							 name:kARAppIconDownloadOperationDidFinishNotification
																						 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(appIconDownloadFailed:)
																							 name:kARAppIconDownloadOperationDidFailNotification
																						 object:nil];
	[app startDownloadingIcon];	
}

- (void)appIconDownloaded:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self.imageView performSelectorOnMainThread:@selector(setAnimationImages:)
																	 withObject:nil
																waitUntilDone:YES];
	[self.imageView performSelectorOnMainThread:@selector(setImage:)
																	 withObject:app.appIcon
																waitUntilDone:YES];	
}

- (void)appIconDownloadFailed:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// TODO: set a placeholder image?
	[self.imageView performSelectorOnMainThread:@selector(setAnimationImages:)
																	 withObject:nil
																waitUntilDone:YES];	
	[self.imageView performSelectorOnMainThread:@selector(setImage:)
																	 withObject:nil
																waitUntilDone:YES];
}

@end
