//
//  BTViewController.m
//  bluetooth-demo
//
//  Created by John Bender on 9/26/13.
//  
//

#import "BTViewController.h"
#import "BTBubbleView.h"
#import "BTBluetoothManager.h"

static const NSInteger nBubbles = 4;
static const CGFloat bubbleSize = 50.;

@interface BTViewController ()
{
    NSArray *bubbles;
}
@end

@implementation BTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self makeBubbles];
    
    [BTBluetoothManager instance]; // 

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bluetoothDataReceived:)
                                                 name:@"bluetoothDataReceived"
                                               object:nil];
}

-(void) makeBubbles
{
    NSMutableArray *b = [NSMutableArray new];

    for( NSInteger i = 1; i < nBubbles; i++ ) {
        BTBubbleView *bubble = [[BTBubbleView alloc] initWithFrame:CGRectMake( bubbleSize, bubbleSize*i,
                                                                              bubbleSize*i, bubbleSize*i )];
        
        bubble.originalIndex = i;
        NSLog (@"Bubble was given index# %d", bubble.originalIndex);
        [self.view addSubview:bubble];
        [b addObject:bubble];
    }
    
    bubbles = [NSArray arrayWithArray:b];
}


-(void) bluetoothDataReceived:(NSNotification*)note
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSDictionary *dict = [note object];
        NSInteger command = [dict[@"command"] intValue];
        switch( command ) {
            case BluetoothCommandPickUp:
            {
                NSInteger viewNumber = [dict[@"viewNumber"] intValue];
                NSLog (@"PICKED UP with ARRAY-based viewNumber %ld", (long)viewNumber);
                
                for( BTBubbleView *bubble in bubbles )
                    if( bubble.originalIndex == viewNumber ) {
                        [bubble performSelectorOnMainThread:@selector(pickUp) withObject:nil waitUntilDone:YES];
                        break;
                    }
            }
            case BluetoothCommandDrop:
            {
                NSInteger viewNumber = [dict[@"viewNumber"] intValue];
                NSLog (@"DROPPED with ARRAY-based viewNumber %ld", (long)viewNumber);

                BTBubbleView *bubble;
                
                for( NSInteger i = 0; i < bubbles.count; i++ ) {
                    bubble = bubbles[i];
                    if( bubble.originalIndex == viewNumber ) {
                        break;
                    }
                }
                
                if( [bubble isKindOfClass:[BTBubbleView class]] )
                    [bubble performSelectorOnMainThread:@selector(drop) withObject:nil waitUntilDone:YES];
                break;
            }
            case BluetoothCommandMove:
            {
                NSInteger viewNumber = [dict[@"viewNumber"] intValue];
                for( BTBubbleView *bubble in bubbles )
                    if( bubble.originalIndex == viewNumber ) {
                        bubble.center = [dict[@"newCenter"] CGPointValue];
                        [bubble performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
                        break;
                }
            }
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
