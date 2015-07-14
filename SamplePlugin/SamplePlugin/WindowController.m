//
//  WindowController.m
//  SamplePlugin
//
//  Created by Rajesh R. on 7/9/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()
@property (weak) IBOutlet NSButton *createIPAButton;
@property (weak) IBOutlet NSPopUpButton *popupButton;
@property (weak) IBOutlet NSTextField *archiveFileName;
@property (nonatomic, strong) NSString *selectedProfile;
@property (nonatomic, strong) NSString *archivePath;
@property (nonatomic, strong) NSTask *task;
@property (weak) IBOutlet NSTextField *ipaPathLabel;

- (IBAction)archiveSelection:(NSButton *)sender;
- (IBAction)createIPAButtonClick:(NSButton *)sender;
- (IBAction)popUpButtonClick:(NSPopUpButton *)sender;

@end
#define PopupDefaultTitle @"Please select provisioning profile"

@implementation WindowController

- (void)windowDidLoad {
    
    [super windowDidLoad];
    NSError *error = nil;
    NSString *path = [@"~/Library/MobileDevice/Provisioning Profiles" stringByExpandingTildeInPath];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mobileprovision'"]];
    NSMutableArray *listItems = [NSMutableArray arrayWithObject:PopupDefaultTitle];
    for (NSString *fileName in files) {
        
        NSString *name = [self nameForProfileAtPath:[path stringByAppendingPathComponent:fileName]];
        [listItems addObject:name];
        
    }
    [self.popupButton addItemsWithTitles:listItems];
}
- (NSString *)nameForProfileAtPath:(NSString *)path {
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    
    CMSDecoderCreate(&decoder);
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
    CMSDecoderFinalizeMessage(decoder);
    CMSDecoderCopyContent(decoder, &dataRef);
    plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
    plist = [plistString propertyList];
    NSString *name = plist[@"Name"];
    return name;
}
- (NSString *)runCommand:(NSString *)commandToRun
{
    self.task = [[NSTask alloc] init];
    [self.task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    [self.task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [self.task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [self.task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
    
}

- (IBAction)archiveSelection:(NSButton *)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowedFileTypes:@[@"xcarchive"]];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            // do something with the url here.
            self.archivePath = url.path;
            self.archiveFileName.stringValue = [self.archivePath lastPathComponent];
        }
    }
}
- (IBAction)createIPAButtonClick:(NSButton *)sender {
    
    if(!self.selectedProfile || [self.selectedProfile isEqualToString:PopupDefaultTitle]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:PopupDefaultTitle];
        [alert runModal];
        
    } else if (!self.archivePath) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Please select archive file"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert runModal];
    } else {
        
        NSString *selectedArchivePath = self.archivePath;
        
        NSString *ipaName = [[selectedArchivePath lastPathComponent] stringByReplacingOccurrencesOfString:@"xcarchive" withString:@"ipa"];
        NSString *ipaPath = [[NSString stringWithFormat:@"~/Desktop/%@",ipaName] stringByExpandingTildeInPath];
        NSString * updateCmd = [NSString stringWithFormat:@"xcodebuild -exportArchive -exportFormat ipa -archivePath \"%@\" -exportPath \"%@\" -exportProvisioningProfile \"%@\"",selectedArchivePath,ipaPath,self.selectedProfile];

        NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 20, 20))];
        [progressIndic setStyle:NSProgressIndicatorSpinningStyle];
        
        [progressIndic startAnimation:nil];
        NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:@"Please wait..."];
        [alert setAccessoryView:progressIndic];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            [self.task interrupt];
        }];

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //back ground thread
            [self runCommand:updateCmd];
            self.ipaPathLabel.stringValue = ipaPath;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window endSheet: [alert window]];
            });
            
        });
    }
}

- (IBAction)popUpButtonClick:(NSPopUpButton *)sender {
     self.selectedProfile =  sender.selectedItem.title;
}
@end
