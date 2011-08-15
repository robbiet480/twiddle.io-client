#import "SocketIO.h"

@interface TWDClient : NSObject <SocketIODelegate> {

  SocketIO *socket;
  
}

@property (retain, nonatomic) SocketIO *socket;

- (id) init;
- (void) socketIODidConnect:(SocketIO *)socket;
- (void) keepAlive:(NSTimer *)timer;
- (void) recievedMessage:(NSString *)message from:(NSString *)sender;

@end