//
//  EmailComposer.m
//
//  Version 1.2
//
//  Created by Guido Sabatini in 2012.
//

#define RETURN_CODE_EMAIL_CANCELLED 0
#define RETURN_CODE_EMAIL_SAVED 1
#define RETURN_CODE_EMAIL_SENT 2
#define RETURN_CODE_EMAIL_FAILED 3
#define RETURN_CODE_EMAIL_NOTSENT 4

#import "EmailComposer.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface EmailComposer ()

-(void) showEmailComposerWithParameters:(NSDictionary*)parameters;
-(void) returnWithCode:(int)code;
-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension;

@end

@implementation EmailComposer

// COMMENT THIS METHOD if you want to use the plugin with versions of cordova < 2.2.0
- (void) showEmailComposer:(CDVInvokedUrlCommand*)command {
    NSDictionary *parameters = [command.arguments objectAtIndex:0];
    [self showEmailComposerWithParameters:parameters];
}

-(void) showEmailComposerWithParameters:(NSDictionary*)parameters {
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    // set subject
    @try {
        NSString* subject = [parameters objectForKey:@"subject"];
        if (subject) {
            [mailComposer setSubject:subject];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set subject; error: %@", exception);
    }
    // set body
    @try {
        NSString* body = [parameters objectForKey:@"body"];
        BOOL isHTML = [[parameters objectForKey:@"bIsHTML"] boolValue];
        if(body) {
            [mailComposer setMessageBody:body isHTML:isHTML];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set body; error: %@", exception);
    }
    // Set recipients
    @try {
        NSArray* toRecipientsArray = [parameters objectForKey:@"toRecipients"];
        if(toRecipientsArray) {
            [mailComposer setToRecipients:toRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set TO recipients; error: %@", exception);
    }
    // CC Recips
    @try {
        NSArray* ccRecipientsArray = [parameters objectForKey:@"ccRecipients"];
        if(ccRecipientsArray) {
            [mailComposer setCcRecipients:ccRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set CC recipients; error: %@", exception);
    }
    // BCC Recips
    @try {
        NSArray* bccRecipientsArray = [parameters objectForKey:@"bccRecipients"];
        if(bccRecipientsArray) {
            [mailComposer setBccRecipients:bccRecipientsArray];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set BCC recipients; error: %@", exception);
    }
    // Attachments
    @try {
        NSArray *attachmentPaths = [parameters objectForKey:@"attachments"];
        if (attachmentPaths) {
            
            // find the application's file path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *appDocsPath = [paths objectAtIndex:0];
            NSArray *attachmentFilenames = [parameters objectForKey:@"filenames"];
            //NSString *persistentPath = [NSString stringWithFormat:@"/%@", [appDocsPath lastPathComponent]];
            
            //for (NSString* path in attachmentPaths) {
            for (int i = 0; i < [attachmentPaths count]; i++) {
                @try {
                    
                    // append the application's full file path to the front of the file path
                    NSString* path = [NSString stringWithFormat:@"%@/%@", appDocsPath, [attachmentPaths objectAtIndex:i]];
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
                    NSString *filename = [NSString stringWithFormat:@"%@.%@", [attachmentFilenames objectAtIndex:i], [path pathExtension]];
                    
                    [mailComposer addAttachmentData:data mimeType:[self getMimeTypeFromFileExtension:[path pathExtension]] fileName:filename];
                }
                @catch (NSException *exception) {
                    NSLog(@"Cannot attach file; error: %@",exception);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EmailComposer - Cannot set attachments; error: %@", exception);
    }
    
    if (mailComposer != nil) {
        [self.viewController presentModalViewController:mailComposer animated:YES];
    } else {
        [self returnWithCode:RETURN_CODE_EMAIL_NOTSENT];
    }
}


// Dismisses the email composition interface when users tap Cancel or Send.
// Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // Notifies users about errors associated with the interface
    int webviewResult = 0;
    
    switch (result) {
        case MFMailComposeResultCancelled:
        webviewResult = RETURN_CODE_EMAIL_CANCELLED;
        break;
        case MFMailComposeResultSaved:
        webviewResult = RETURN_CODE_EMAIL_SAVED;
        break;
        case MFMailComposeResultSent:
        webviewResult =RETURN_CODE_EMAIL_SENT;
        break;
        case MFMailComposeResultFailed:
        webviewResult = RETURN_CODE_EMAIL_FAILED;
        break;
        default:
        webviewResult = RETURN_CODE_EMAIL_NOTSENT;
        break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
    [self returnWithCode:webviewResult];
}

// Call the callback with the specified code
-(void) returnWithCode:(int)code {
    [self writeJavascript:[NSString stringWithFormat:@"window.plugins.emailComposer._didFinishWithResult(%d);", code]];
}

// Retrieve the mime type from the file extension
-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension {
    if (!extension)
    return nil;
    CFStringRef pathExtension, type;
    // Get the UTI from the file's extension
    pathExtension = (__bridge CFStringRef)extension;
    type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    
    // Converting UTI to a mime type
    return (__bridge NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
}

@end