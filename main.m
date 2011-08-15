#import "TWDClient.h"

int main(int argc, char **argv, char **envp) {
  
  NSLog(@"Starting now");
  
  
	//start a pool
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  //initialize our TWDClient
  TWDClient *obj = [[TWDClient alloc] init];

  //start a timer so that the process does not exit
  NSDate *now = [[NSDate alloc] init];
  NSTimer *timer = [[NSTimer alloc] initWithFireDate:now
  interval:4
  target:obj
  selector:@selector(keepAlive:)
  userInfo:nil
  repeats:YES];
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
  [runLoop run];

  [pool release];
  NSLog(@"Finished Everything, now closing");
  return 0;
}

// vim:ft=objc
