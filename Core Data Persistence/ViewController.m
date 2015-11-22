//
//  ViewController.m
//  Core Data Persistence
//
//  Created by 张光发 on 15/11/22.
//  Copyright © 2015年 张光发. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString * const kLineEntityName = @"Line";
static NSString * const kLineNumberKey = @"lineNumber";
static NSString * const kLineTextKey = @"lineText";

@interface ViewController ()
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *lineFields;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获得应用委托的引用
    AppDelegate *appDelegate=[UIApplication sharedApplication].delegate;
    //根据委托引用获取托管对象上下文
    NSManagedObjectContext *context=[appDelegate managedObjectContext];
    //创建一个获取请求
    NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:kLineEntityName];
    
    //根据获取请求获取数据
    NSError *error;
    NSArray *object=[context executeFetchRequest:request error:&error];
    if (object==NULL) {
        NSLog(@"发生错误了1");
    }
    
    //遍历获取的结果，并恢复到界面
    for (NSManagedObject *oneObject in object) {
        int linNum=[[oneObject valueForKey:kLineNumberKey] intValue];
        NSString *lineText=[oneObject valueForKey:kLineTextKey];
        
        UITextField *theFiled=self.lineFields[linNum];
        theFiled.text=lineText;
    }
    
    //订阅通知
    UIApplication *app=[UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
}

//通知回调
-(void)applicationWillResignActive:(NSNotificationCenter *)notification
{
    //获取应用委托引用
    AppDelegate *appdelegate=[UIApplication sharedApplication].delegate;
    //根据委托获取上下文
    NSManagedObjectContext *context=[appdelegate managedObjectContext];
    NSError *error;
    for (int i=0; i<4; i++) {
        //获取界面中的文本框
        UITextField *theFiled=self.lineFields[i];
        //创建获取请求
        NSFetchRequest *request=[[NSFetchRequest alloc] initWithEntityName:kLineEntityName];
        //创建一个谓语
        NSPredicate *pred=[NSPredicate predicateWithFormat:@"(%s=%d)",kLineNumberKey,i];
        //获取请求增加谓语条件
        [request setPredicate:pred];
        
        //根据获取请求搜索数据
        NSArray *object = [context executeFetchRequest:request error:&error];
        if (object==NULL) {
            NSLog(@"发生错误了2");
        }
        
        //判断搜索结果是否为空，为空新创建，否则加载
        NSManagedObject *theLine=nil;
        if ([object count]>0) {
            theLine=[object objectAtIndex:0];
        }else{
            theLine=[NSEntityDescription insertNewObjectForEntityForName:kLineEntityName inManagedObjectContext:context];
        }
        //设置值
        [theLine setValue:[NSNumber numberWithInt:i] forKey:kLineNumberKey];
        [theLine setValue:theFiled.text forKey:kLineTextKey];
    }
    //通知委托上下文保存修改
    [appdelegate saveContext];
}

@end
