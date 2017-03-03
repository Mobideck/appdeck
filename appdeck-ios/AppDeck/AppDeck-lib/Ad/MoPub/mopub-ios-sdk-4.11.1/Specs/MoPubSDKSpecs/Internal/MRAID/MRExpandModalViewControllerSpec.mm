#import "MRExpandModalViewController.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRExpandModalViewController (Specs)

@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL applicationHidesStatusBar;

@end

SPEC_BEGIN(MRExpandModalViewControllerSpec)

describe(@"MRExpandModalViewController", ^{
    __block BOOL applicationHidesStatusBar;
    __block UIApplication *application;
    __block MRExpandModalViewController *expandViewController;

    beforeEach(^{
        applicationHidesStatusBar = [UIApplication sharedApplication].statusBarHidden;
        expandViewController = [[MRExpandModalViewController alloc] initWithOrientationMask:UIInterfaceOrientationMaskPortrait];
        application = [UIApplication sharedApplication];
        spy_on(application);
    });

    describe(@"Hiding and restoring status bar", ^{
        context(@"when hiding", ^{
            beforeEach(^{
                // Make the vc's internal variable the opposite of what the status bar's hidden property is for variable validation
                // purposes.
                expandViewController.applicationHidesStatusBar = ![UIApplication sharedApplication].statusBarHidden;
                [expandViewController hideStatusBar];
            });

            it(@"should record whether or not the status bar is currently hidden", ^{
                expandViewController.applicationHidesStatusBar should equal([UIApplication sharedApplication].statusBarHidden);
            });

            it(@"should mark the status bar as hidden", ^{
                expandViewController.statusBarHidden should equal(YES);
            });

            it(@"should attempt to hide the status bar", ^{
                application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(YES);
            });

            context(@"when trying to hide twice without restoring", ^{
                beforeEach(^{
                    [(id<CedarDouble>)application reset_sent_messages];
                    [expandViewController hideStatusBar];
                });

                it(@"should not attempt to hide the status bar again", ^{
                    application should_not have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:));
                });

                context(@"when restoring after (hide, hide)", ^{
                    beforeEach(^{
                        [expandViewController restoreStatusBarVisibility];
                    });

                    it(@"should have the correct value for applicationHidesStatusBar still", ^{
                        expandViewController.applicationHidesStatusBar should equal(applicationHidesStatusBar);
                    });

                    it(@"should set its internal status bar hidden variable to whatever the application had set the status bar visibility to", ^{
                        expandViewController.statusBarHidden should equal(expandViewController.applicationHidesStatusBar);
                    });

                    it(@"should attempt to restore the status bar's visibility", ^{
                        application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(expandViewController.applicationHidesStatusBar);
                    });

                    context(@"when hiding after (hide, hide, restore)", ^{
                        beforeEach(^{
                            [(id<CedarDouble>)application reset_sent_messages];
                            [expandViewController hideStatusBar];
                        });

                        it(@"should record whether or not the status bar is currently hidden", ^{
                            expandViewController.applicationHidesStatusBar should equal(applicationHidesStatusBar);
                        });

                        it(@"should mark the status bar as hidden", ^{
                            expandViewController.statusBarHidden should equal(YES);
                        });

                        it(@"should attempt to hide the status bar again", ^{
                            application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(YES);
                        });

                        context(@"when restoring after (hide, hide, restore, hide)", ^{
                            beforeEach(^{
                                [expandViewController restoreStatusBarVisibility];
                            });

                            it(@"should have the correct value for applicationHidesStatusBar still", ^{
                                expandViewController.applicationHidesStatusBar should equal(applicationHidesStatusBar);
                            });

                            it(@"should set its internal status bar hidden variable to whatever the application had set the status bar visibility to", ^{
                                expandViewController.statusBarHidden should equal(expandViewController.applicationHidesStatusBar);
                            });

                            it(@"should attempt to restore the status bar's visibility", ^{
                                application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(expandViewController.applicationHidesStatusBar);
                            });
                        });
                    });
                });
            });

            context(@"when restoring after (hide)", ^{
                beforeEach(^{
                    // Make the vc's internal status bar hidden variable the opposite of what it should be for variable validation
                    // purposes.
                    expandViewController.statusBarHidden = !expandViewController.applicationHidesStatusBar;
                    [expandViewController restoreStatusBarVisibility];
                });

                it(@"should set its internal status bar hidden variable to whatever the application had set the status bar visibility to", ^{
                    expandViewController.statusBarHidden should equal(expandViewController.applicationHidesStatusBar);
                });

                it(@"should attempt to restore the status bar's visibility", ^{
                    application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(expandViewController.applicationHidesStatusBar);
                });

                context(@"when restoring after (hide, restore)",^{
                    beforeEach(^{
                        [(id<CedarDouble>)application reset_sent_messages];
                        [expandViewController restoreStatusBarVisibility];
                    });

                    it(@"should attempt to restore the status bar's visibility with applicationHidesStatusBar again", ^{
                        application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(expandViewController.applicationHidesStatusBar);
                    });

                    context(@"when hiding after (hide, restore, restore)", ^{
                        beforeEach(^{
                            [(id<CedarDouble>)application reset_sent_messages];
                            [expandViewController hideStatusBar];
                        });

                        it(@"should record whether or not the status bar is currently hidden", ^{
                            expandViewController.applicationHidesStatusBar should equal([UIApplication sharedApplication].statusBarHidden);
                        });

                        it(@"should mark the status bar as hidden", ^{
                            expandViewController.statusBarHidden should equal(YES);
                        });

                        it(@"should not attempt to hide the status bar again", ^{
                            application should have_received(@selector(mp_preIOS7setApplicationStatusBarHidden:)).with(YES);
                        });
                    });
                });
            });
        });
    });
});

SPEC_END
