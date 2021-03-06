//
//  MHAuthenticationViewController.m
//  MyHub
//
//  Created by Arcterus on 8/11/13.
//  Copyright (c) 2013 kRaken Research. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

#import "MHAuthenticationViewController.h"
#import "MHMainViewController.h"
#import "MHAppDelegate.h"
#import "SVProgressHUD.h"

@interface MHAuthenticationViewController ()

- (void)initSubviews;
- (void)sendSignin:(id)sender;
- (void)animationDone:(UIViewController *)controller;
- (void)transitionToMain;

@end

@implementation MHAuthenticationViewController {
	UITextField *_username;
	UITextField *_password;
	MHKeychainItemWrapper *_keychain;
}

- (id)init {
	if(self = [super init]) {
		_keychain = [[MHKeychainItemWrapper alloc] initWithIdentifier:@"MyHubLogin" accessGroup:nil];
	}
	return self;
}

// XXX: ugly (needs to be re-factored)
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	NSString *name = [_keychain objectForKey:(__bridge id)(kSecAttrAccount)];
	if(name && ![name isEqualToString:@""]) {
		OCTUser *user = [OCTUser userWithLogin:name server:OCTServer.dotComServer];
		OCTClient *client = [OCTClient authenticatedClientWithUser:user token:[[NSString alloc] initWithData:[_keychain objectForKey:(__bridge id)(kSecValueData)] encoding:NSUTF8StringEncoding]];
		[SVProgressHUD showWithStatus:@"Verifying..." maskType:SVProgressHUDMaskTypeGradient];
		
		[[client fetchUserInfo] subscribeError:^(NSError *error) {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				if([error code] == OCTClientErrorConnectionFailed || [error code] == OCTClientErrorServiceRequestFailed) {
					[SVProgressHUD showErrorWithStatus:@"Network Error"];
				} else if([error code] == OCTClientErrorAuthenticationFailed) {
					[SVProgressHUD showErrorWithStatus:@"Invalid Username or Password"];
				} else {
					[SVProgressHUD showErrorWithStatus:@"Unknown Error"];
				}
				[self initSubviews];
			}];
		} completed:^ {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[SVProgressHUD showSuccessWithStatus:@"Success"];
				
				MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
				appDelegate.client = client;
				
				[self transitionToMain];
			}];
		}];
	} else {
		[self initSubviews];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == _username) {
		[_password becomeFirstResponder];
	} else if(textField == _password) {
		[self sendSignin:textField];
	} else {
		return YES;
	}
	return NO;
}

- (void)sendSignin:(id)sender {
	if([_password.text length] > 0 && [_username.text length] > 0) {
		[self.view endEditing:YES];
		OCTClient __block *client = nil;
		OCTUser *user = [OCTUser userWithLogin:_username.text server:OCTServer.dotComServer];
		
		[SVProgressHUD showWithStatus:@"Verifying..." maskType:SVProgressHUDMaskTypeGradient];
		
		[[OCTClient signInAsUser:user password:_password.text oneTimePassword:nil scopes:OCTClientAuthorizationScopesUser]
		 subscribeNext:^(OCTClient *authClient) {
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
				 [SVProgressHUD showSuccessWithStatus:@"Success"];
				 client = authClient;
			 }];
		 } error:^(NSError *error) {
			 if([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
				 //[self showTwoFactorAuthField];
				 exit(0);
			 } else {
				 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
					 if([error code] == OCTClientErrorConnectionFailed || [error code] == OCTClientErrorServiceRequestFailed) {
						 [SVProgressHUD showErrorWithStatus:@"Network Error"];
					 } else if([error code] == OCTClientErrorAuthenticationFailed) {
						 [SVProgressHUD showErrorWithStatus:@"Invalid Username or Password"];
					 } else {
						 [SVProgressHUD showErrorWithStatus:@"Unknown Error"];
					 }
				 }];
			 }
		 } completed:^{
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
				 if(client) {
					 MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
					 appDelegate.client = client;
					 [_keychain setObject:client.user.login forKey:(__bridge id)(kSecAttrAccount)];
					 [_keychain setObject:client.token forKey:(__bridge id)(kSecValueData)];
					 [self transitionToMain];
				 }
			 }];
		 }];
	}
}

- (void)animationDone:(UIViewController *)controller {
	MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.window.rootViewController = controller;
}

- (void)transitionToMain {
	MHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	// Slide-up transition
	CGFloat duration = 0.7;
	MHMainViewController *mainView = [[MHMainViewController alloc] init];
	[mainView viewWillAppear:YES];
	[self viewWillDisappear:YES];
	[appDelegate.window insertSubview:mainView.view belowSubview:self.view];
	[mainView viewDidAppear:YES];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	mainView.view.transform = CGAffineTransformMakeTranslation(0, 0);
	self.view.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.size.height);
	[UIView commitAnimations];
	[self performSelector:@selector(animationDone:) withObject:mainView afterDelay:duration];
}

- (void)initSubviews {
	CGSize size = self.view.frame.size;
	
	UILabel *label = [[UILabel alloc] init];
	label.translatesAutoresizingMaskIntoConstraints = NO;
	label.font = [UIFont systemFontOfSize:64.0];
	[label setText:@"GitHub"];
	
	_username = [[UITextField alloc] initWithFrame:CGRectMake(40.0f, 200.0f, size.width - 80.0f, 30.0f)];
	_username.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
	_username.placeholder = @"Username";
	_username.borderStyle = UITextBorderStyleRoundedRect;
	_username.clearButtonMode = UITextFieldViewModeWhileEditing;
	_username.returnKeyType = UIReturnKeyNext;
	_username.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_username.autocorrectionType = UITextAutocorrectionTypeNo;
	_username.delegate = self;
	
	_password = [[UITextField alloc] init];
	_password.translatesAutoresizingMaskIntoConstraints = NO;
	_password.placeholder = @"Password";
	_password.borderStyle = UITextBorderStyleRoundedRect;
	_password.clearButtonMode = UITextFieldViewModeWhileEditing;
	_password.returnKeyType = UIReturnKeyGo;
	_password.delegate = self;
	[_password setSecureTextEntry:YES];
	
	UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	submit.translatesAutoresizingMaskIntoConstraints = NO;
	[submit setTitle:@"Sign in" forState:UIControlStateNormal];
	[submit addTarget:self action:@selector(sendSignin:) forControlEvents:UIControlEventTouchDown];
	
	[self.view addSubview:label];
	[self.view addSubview:_username];
	[self.view addSubview:_password];
	[self.view addSubview:submit];
	
	[self.view sendSubviewToBack:label];
	[self.view sendSubviewToBack:_username];
	[self.view sendSubviewToBack:_password];
	[self.view sendSubviewToBack:submit];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_username attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_username attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_username attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_username attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_password attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_username attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:submit attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_password attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:submit attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_password attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
}

@end
