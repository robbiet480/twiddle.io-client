#import "TWDClient.h"
#import "SocketIO.h"

@class CTMessage, CTMessagePart;
@protocol CTMessageAddress, NSCopying;
extern id CTTelephonyCenterGetDefault();

// header of CoreTelephony
extern NSString* const kCTSMSMessageReceivedNotification;
extern NSString* const kCTSMSMessageReplaceReceivedNotification;
extern NSString* const kCTSIMSupportSIMStatusNotInserted;
extern NSString* const kCTSIMSupportSIMStatusReady;
extern NSString* const kCTCallStatusChangeNotification;

id CTTelephonyCenterGetDefault(void);
void CTTelephonyCenterAddObserver(id,id,CFNotificationCallback,NSString*,void*,int);
void CTTelephonyCenterRemoveObserver(id,id,NSString*,void*);
int CTSMSMessageGetUnreadCount(void);

int CTSMSMessageGetRecordIdentifier(void * msg);
NSString * CTSIMSupportGetSIMStatus();   //»ñÈ¡sim¿¨×´Ì¬£¬kCTSIMSupportSIMStatusNotInserted±íÊ¾Ã»ÓÐsim¿¨
NSString * CTSIMSupportCopyMobileSubscriberIdentity();  //»ñÈ¡imsiºÅÂë£¬ÀáÅ£ÂúÃæ°¡£¬ÎÒÔ­À´¶¼ÊÇÓÃAT+CCIDÀ´»ñÈ¡µÄiccidÊ¶±ðÓÃ»§

id  CTSMSMessageCreate(void* unknow/*always 0*/,NSString* number,NSString* text);
void * CTSMSMessageCreateReply(void* unknow/*always 0*/,void * forwardTo,NSString* text);

void* CTSMSMessageSend(id server,id msg);

NSString *CTSMSMessageCopyAddress(void *, void *);
NSString *CTSMSMessageCopyText(void *, void *);
static TWDClient* client;
@interface CTMessageCenter : NSObject
{
}

+ (id)sharedMessageCenter;
- (BOOL)sendSMSWithText:(id)arg1 serviceCenter:(id)arg2 toAddress:(id)arg3;
- (CTMessage *)incomingMessageWithId:(int)id;
@end

@implementation TWDClient

@synthesize socket;

void callback(CFNotificationCenterRef center, void *observer, CFStringRef namecf, const void *object, CFDictionaryRef infocf) {
  NSString *name = (NSString *)namecf;
  NSDictionary *info = (NSDictionary *)infocf;
  fprintf(stderr, "Notification intercepted: %s\n", [name UTF8String]);
  if([name isEqualToString:@"kCTMessageReceivedNotification"] && info)
  {
    NSNumber* messageType = [info valueForKey:@"kCTMessageTypeKey"];
    if([messageType isEqualToNumber:[NSNumber numberWithInt:1/*empirically determined!*/]])
    {
     NSNumber* messageID = [info valueForKey:@"kCTMessageIdKey"];
     CTMessageCenter* mc = [CTMessageCenter sharedMessageCenter];
     CTMessage* msg = [mc incomingMessageWithId:[messageID intValue]];
     NSObject<CTMessageAddress>* phonenumber = [msg sender];

     NSString *senderNumber = (NSString*)[phonenumber canonicalFormat];
     NSString *sender = (NSString*)[phonenumber encodedString];
     CTMessagePart* msgPart = [[msg items] objectAtIndex:0]; //for single-part msgs
     NSData *smsData = [msgPart data];
     NSString *smsText = [[NSString alloc] initWithData:smsData encoding:NSUTF8StringEncoding];
     NSLog([client description]);
     [client recievedMessage:[smsText UTF8String] from:[senderNumber UTF8String]];
     //fprintf(stderr, "SMS Message from %s / %s: \"%s\"\n",[senderNumber UTF8String],[sender UTF8String],[smsText UTF8String]);
    }
  }
  return;
}

- (id) init {
    if ( (self = [super init]) ) {
      client = self;
      	SocketIO *socketIO = [[SocketIO alloc] initWithDelegate:self];
      	[socketIO connectToHost:@"Annabelle.local" onPort:3000];
      	
      	id ct = CTTelephonyCenterGetDefault();
      	CTTelephonyCenterAddObserver(ct, NULL, callback, NULL, NULL, CFNotificationSuspensionBehaviorHold);
        
    }
    return self;
}

- (void) socketIODidConnect:(SocketIO *)aSocket {
  self.socket = aSocket;
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: @"asdfaasfa42432asdf", @"UDID", nil];
  [self.socket sendEvent:@"phone-start" withData:data];
  return;
}

- (void) socketIO:(SocketIO *)aSocket didReceiveEvent:(SocketIOPacket *)packet {
  NSLog(@"Packet Recieved.");
  NSString *recip = @"";
  NSString *mess = @"";
  if (aSocket == self.socket) {
    NSLog(@"packet name: %@", packet.name);
    if ([packet.name isEqualToString:@"send-message"]) {
      // send a text message
      NSDictionary *data = [packet dataAsJSON];
      NSArray *args = [data objectForKey:@"args"];
      for (NSDictionary *item in args) {
        recip = [item objectForKey:@"recipient"];
        mess = [item objectForKey:@"message"];
      }
      [[CTMessageCenter sharedMessageCenter]  sendSMSWithText:mess serviceCenter:nil toAddress:recip];
    }
  }
}

- (void) recievedMessage:(const char *)messagecf from:(const char *)sendercf {
  NSString *message = [NSString stringWithCString:messagecf encoding:NSUTF8StringEncoding];
  NSString *sender = [NSString stringWithCString:sendercf encoding:NSUTF8StringEncoding];
  //NSLog(@"message %@ sender %@", message, sender);
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: sender , @"sender", message, @"message", @"asdfaasfa42432asdf" , @"UDID", nil];
  //NSLog(@"world");
  [self.socket sendEvent:@"recieve-message" withData:data];
}

- (void) keepAlive:(NSTimer *)timer {
  [timer description];
  //NSLog(@"keep alive");
}

@end