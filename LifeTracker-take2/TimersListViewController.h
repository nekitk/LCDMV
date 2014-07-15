#import <UIKit/UIKit.h>

@interface TimersListViewController (Workaround)

- (IBAction)unwindToTimersFromFlowScreen: (UIStoryboardSegue *)segue;
- (IBAction)unwindToTimersFromAddScreen: (UIStoryboardSegue *)segue;

@end