//
//  ModelGraphViewController.m
//  RoleModel
//
//  Created by Brian Wang on 3/22/15.
//  Copyright (c) 2015 RoleModel. All rights reserved.
//

#import "ModelGraphViewController.h"

@interface ModelGraphViewController ()

@end

@implementation ModelGraphViewController {
    CPTScatterPlot* _pitchPlot;
    CPTScatterPlot* _rollPlot;
    CPTScatterPlot* _yawPlot;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: hostView];
    
    // Create a CPTGraph object and add to hostView
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.hostedGraph = graph;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    
    // Note that these CPTPlotRange are defined by START and LENGTH (not START and END) !!
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat(100.0)]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0 ) length:CPTDecimalFromFloat([_pitchE count] )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    _pitchPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    _rollPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    _yawPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    
    // Let's keep it simple and let this class act as datasource (therefore we implemtn <CPTPlotDataSource>)
    _pitchPlot.dataSource = self;
    _rollPlot.dataSource = self;
    _yawPlot.dataSource = self;

    
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:_pitchPlot toPlotSpace:graph.defaultPlotSpace];
    [graph addPlot:_rollPlot toPlotSpace:graph.defaultPlotSpace];
    [graph addPlot:_yawPlot toPlotSpace:graph.defaultPlotSpace];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:_pitchPlot, _rollPlot, _yawPlot, nil]];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.3f)];
    plotSpace.yRange = yRange;
    
    CPTMutableLineStyle *pitchLineStyle = [_pitchPlot.dataLineStyle mutableCopy];
    pitchLineStyle.lineWidth = 2.5;
    pitchLineStyle.lineColor = [CPTColor redColor];
    _pitchPlot.dataLineStyle = pitchLineStyle;
    CPTMutableLineStyle *pitchSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    pitchSymbolLineStyle.lineColor = [CPTColor redColor];
    CPTPlotSymbol *pitchSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    pitchSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
    pitchSymbol.lineStyle = pitchSymbolLineStyle;
    pitchSymbol.size = CGSizeMake(6.0f, 6.0f);
    _pitchPlot.plotSymbol = pitchSymbol;
    
    CPTMutableLineStyle *rollLineStyle = [_rollPlot.dataLineStyle mutableCopy];
    rollLineStyle.lineWidth = 1;
    rollLineStyle.lineColor = [CPTColor yellowColor];
    _rollPlot.dataLineStyle = rollLineStyle;
    CPTMutableLineStyle *rollSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    rollSymbolLineStyle.lineColor = [CPTColor yellowColor];
    CPTPlotSymbol *rollSymbol = [CPTPlotSymbol starPlotSymbol];
    rollSymbol.fill = [CPTFill fillWithColor:[CPTColor yellowColor]];
    rollSymbol.lineStyle = rollSymbolLineStyle;
    rollSymbol.size = CGSizeMake(6.0f, 6.0f);
    _rollPlot.plotSymbol = rollSymbol;
    
    CPTMutableLineStyle *yawLineStyle = [_yawPlot.dataLineStyle mutableCopy];
    yawLineStyle.lineWidth = 2;
    yawLineStyle.lineColor = [CPTColor blueColor];
    _yawPlot.dataLineStyle = yawLineStyle;
    CPTMutableLineStyle *yawSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    yawSymbolLineStyle.lineColor = [CPTColor blueColor];
    CPTPlotSymbol *yawSymbol = [CPTPlotSymbol diamondPlotSymbol];
    yawSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
    yawSymbol.lineStyle = yawSymbolLineStyle;
    yawSymbol.size = CGSizeMake(6.0f, 6.0f);
    _yawPlot.plotSymbol = yawSymbol;
    
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;

    CPTAxis *x = axisSet.xAxis;
    x.title = @"Time over seconds";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 6.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    NSMutableSet *xLabels = [NSMutableSet set];
    NSMutableSet *xLocations = [NSMutableSet set];
    double secondLabels = 0;
    int i = 0;
    for (int index = 0; index < [_pitchE count]; index++) {
        if (index % 50 == 0 && index != 0) {
            secondLabels += 0.5;
            NSString *str = [NSString stringWithFormat:@"%.1f", secondLabels];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:str  textStyle:x.labelTextStyle];
            label.tickLocation = CPTDecimalFromCGFloat(index);
            if (label) {
                [xLabels addObject: label];
                [xLocations addObject:[NSNumber numberWithFloat: index]];
            }
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"% error";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -15.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    NSInteger majorIncrement = 20;
    NSInteger minorIncrement = 10;
    CGFloat yMax = 100.0f;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [_pitchE count]; // Our sample graph contains 9 'points'
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithDouble:index];
    } else {
        double d;
        if (plot == _pitchPlot) {
            d = [[_pitchE objectAtIndex:index] doubleValue];
        } else if (plot == _rollPlot) {
            d = [[_rollE objectAtIndex:index] doubleValue];
        } else if (plot == _yawPlot) {
            d = [[_yawE objectAtIndex:index] doubleValue];
        }
        return [NSNumber numberWithDouble: d * 100.0];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction) close {
    [self.delegate modelGraphViewControllerDidClose:self];
}

@end
