#import "NativeTextInput.h"
#import "NativeTextInputDelegate.h"

@implementation NativeInputField {
    UITextView* _textView;
    int64_t _viewId;
    FlutterMethodChannel* _channel;
    NativeTextInputDelegate* _delegate;
}


- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    
    if ([super init]) {
        NSString* channelName = [NSString stringWithFormat:@"flutter_native_text_input%lld", viewId];
        _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        
        _viewId = viewId;
        
        _textView = [[UITextView alloc] initWithFrame:frame];
        //_textView.text = args[@"placeholder"];
        //_textView.textColor = UIColor.lightGrayColor;
        
        _textView.text = args[@"text"];
        _textView.textColor = UIColor.blackColor;
        
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.backgroundColor = UIColor.clearColor;
        _textView.keyboardType = [self keyboardTypeFromString:args[@"keyboardType"]];
        _textView.textAlignment = [self textAlignmentFromString:args[@"textAlign"]];
        _textView.textContainer.maximumNumberOfLines = [args[@"maxLines"] intValue];
        _textView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
        
        //bug fix
        if ([_textView.text  isEqualToString:@""]) {
            _textView.text = args[@"placeholder"];
            _textView.textColor = UIColor.lightGrayColor;
        }
        
        
        if (@available(iOS 10.0, *)) {
            _textView.textContentType = [self textContentTypeFromString:args[@"textContentType"]];
        }
        
        _delegate = [[NativeTextInputDelegate alloc] initWithChannel:_channel arguments:args];
        _textView.delegate = _delegate;
        
        __weak __typeof__(self) weakSelf = self;
        [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];
    }
    return self;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([[call method] isEqualToString:@"unfocus"]) {
        [self onUnFocus:call result:result];
    } else if ([[call method] isEqualToString:@"focus"]) {
        [self onFocus:call result:result];
    } else if ([[call method] isEqualToString:@"setText"]) {
        [self onSetText:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)onFocus:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_textView becomeFirstResponder];
    result(nil);
}

- (void)onUnFocus:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_textView resignFirstResponder];
    result(nil);
}

- (void)onSetText:(FlutterMethodCall*)call result:(FlutterResult)result {
    _textView.text = call.arguments[@"text"];
    result(nil);
}

- (UIView*)view {
    return _textView;
}

- (UIKeyboardType)keyboardTypeFromString:(NSString*)keyboardType {
    if (!keyboardType || [keyboardType isKindOfClass:[NSNull class]]) {
        return UIKeyboardTypeDefault;
    }
    
    if ([keyboardType isEqualToString:@"KeyboardType.asciiCapable"]) {
        return UIKeyboardTypeASCIICapable;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.numbersAndPunctuation"]) {
        return UIKeyboardTypeNumbersAndPunctuation;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.url"]) {
        return UIKeyboardTypeURL;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.numberPad"]) {
        return UIKeyboardTypeNumberPad;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.phonePad"]) {
        return UIKeyboardTypePhonePad;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.namePhonePad"]) {
        return UIKeyboardTypeNamePhonePad;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.emailAddress"]) {
        return UIKeyboardTypeEmailAddress;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.decimalPad"]) {
        return UIKeyboardTypeDecimalPad;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.twitter"]) {
        return UIKeyboardTypeTwitter;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.webSearch"]) {
        return UIKeyboardTypeWebSearch;
    }
    else if ([keyboardType isEqualToString:@"KeyboardType.asciiCapableNumberPad"]) {
        if (@available(iOS 10.0, *)) {
            return UIKeyboardTypeASCIICapableNumberPad;
        } else {
            return UIKeyboardTypeNumberPad;
        }
    }
    
    return UIKeyboardTypeDefault;
}

- (UITextContentType)textContentTypeFromString:(NSString*)contentType {
    if (!contentType || [contentType isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if (@available(iOS 10.0, *)) {
        
        if ([contentType isEqualToString:@"TextContentType.username"]) {
            if (@available(iOS 11.0, *)) {
                return UITextContentTypeUsername;
            } else {
                return nil;
            }
        }
        
        if ([contentType isEqualToString:@"TextContentType.password"]) {
            if (@available(iOS 11.0, *)) {
                return UITextContentTypePassword;
            } else {
                return nil;
            }
        }
        
        if ([contentType isEqualToString:@"TextContentType.newPassword"]) {
            if (@available(iOS 12.0, *)) {
                return UITextContentTypeNewPassword;
            } else if (@available(iOS 11.0, *)) {
                return UITextContentTypePassword;
            } else {
                return nil;
            }
        }
        
        if ([contentType isEqualToString:@"TextContentType.oneTimeCode"]) {
            if (@available(iOS 12.0, *)) {
                return UITextContentTypeOneTimeCode;
            } else {
                return nil;
            }
        }
        
        NSDictionary *dict =
        @{
          @"TextContentType.name":                  UITextContentTypeName,
          @"TextContentType.namePrefix":            UITextContentTypeNamePrefix,
          @"TextContentType.givenName":             UITextContentTypeGivenName,
          @"TextContentType.middleName":            UITextContentTypeMiddleName,
          @"TextContentType.familyName":            UITextContentTypeFamilyName,
          @"TextContentType.nameSuffix":            UITextContentTypeNameSuffix,
          @"TextContentType.nickname":              UITextContentTypeNickname,
          @"TextContentType.jobTitle":              UITextContentTypeJobTitle,
          @"TextContentType.organizationName":      UITextContentTypeOrganizationName,
          @"TextContentType.location":              UITextContentTypeLocation,
          @"TextContentType.fullStreetAddress":     UITextContentTypeFullStreetAddress,
          @"TextContentType.streetAddressLine1":    UITextContentTypeStreetAddressLine1,
          @"TextContentType.streetAddressLine2":    UITextContentTypeStreetAddressLine2,
          @"TextContentType.city":                  UITextContentTypeAddressCity,
          @"TextContentType.addressState":          UITextContentTypeAddressState,
          @"TextContentType.addressCityAndState":   UITextContentTypeAddressCityAndState,
          @"TextContentType.sublocality":           UITextContentTypeSublocality,
          @"TextContentType.countryName":           UITextContentTypeCountryName,
          @"TextContentType.postalCode":            UITextContentTypePostalCode,
          @"TextContentType.telephoneNumber":       UITextContentTypeTelephoneNumber,
          @"TextContentType.emailAddress":          UITextContentTypeEmailAddress,
          @"TextContentType.url":                   UITextContentTypeURL,
          @"TextContentType.creditCardNumber":      UITextContentTypeCreditCardNumber
          };
        
        return dict[contentType];
    } else {
        return nil;
    }
}

- (NSTextAlignment)textAlignmentFromString:(NSString*)textAlignment {
    if (!textAlignment || [textAlignment isKindOfClass:[NSNull class]]) {
        return NSTextAlignmentNatural;
    }
    
    if ([textAlignment isEqualToString:@"TextAlign.left"]) {
        return NSTextAlignmentLeft;
    } else if ([textAlignment isEqualToString:@"TextAlign.right"]) {
        return NSTextAlignmentRight;
    } else if ([textAlignment isEqualToString:@"TextAlign.center"]) {
        return NSTextAlignmentCenter;
    } else if ([textAlignment isEqualToString:@"TextAlign.justify"]) {
        return NSTextAlignmentJustified;
    } else if ([textAlignment isEqualToString:@"TextAlign.end"]) {
        return ([self layoutDirection] == UIUserInterfaceLayoutDirectionLeftToRight)
            ? NSTextAlignmentRight
            : NSTextAlignmentLeft;
    }
    
    // TextAlign.start
    return NSTextAlignmentNatural;
}

- (UIUserInterfaceLayoutDirection)layoutDirection {
    if (@available(iOS 9.0, *)) {
        return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:_textView.semanticContentAttribute];
    }
    
    return UIApplication.sharedApplication.userInterfaceLayoutDirection;
}

@end
