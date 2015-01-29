//
//  main.m
//  TNSApp
//
//  Created by Panayot Cankov on 7/30/14.
//  Copyright (c) 2014 TNS. All rights reserved.
//

int main(int argc, char * argv[])
{
    @autoreleasepool {
        TNSRuntime *runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];
        [TNSRuntimeInspector setLogsToSystemConsole:YES];

        JSValueRef error = NULL;
        [runtime executeModule:@"./bootstrap" error:&error];

        if (error) {
            return -1;
        } else {
            return 0;
        }
    }
}
