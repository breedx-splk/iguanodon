import React, {Component} from 'react';
import Chartist from 'chartist';
import Title from './Title';
import Subselect from './Subselect';

export default class Chart extends Component {

    constructor(props){
        super(props);
        this.state = {
        };
    }

    render() {
        const title = this.props.chartProps.title;
        const chartProps = this.props.chartProps;

        // console.log(`chart sees: `)
        // console.log(this.props.chartProps);

        const subsel = this.buildSubsel()
        const seriesData = this.buildSeriesData(chartProps);
        const data = {
            labels: chartProps.labels,
            series: seriesData
        };
        const options = {
            low: 0,
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0.4
            })
        }
        if(data.labels){
            const chart = new Chartist.Line('#chart', data, options);
        }

        return (
            <React.Fragment>
                <Title>{title}</Title>
                {subsel}
                <div id='chart' className="ct-chart ct-perfect-fourth">
                </div>
            </React.Fragment>
        );
    }

    radioSelChanged(selection){
        this.setState({
            selectedSubItem: selection
        }); // force redraw with new selection
    }

    buildSubsel() {
        const chartProps = this.props.chartProps;
        if (chartProps?.series?.length <= 2) {
            return <span/>
        }
        // const selectedItem = chartProps.selectedSubItem || chartProps.series[0].prefix;
        const selectedItem = this.state.selectedSubItem || chartProps.series[0].prefix;
        return <Subselect chartProps={chartProps} radioChanged={x => this.radioSelChanged(x)} selectedItem={selectedItem}/>
    }

    buildSeriesData(chartProps) {
        if(chartProps?.series?.length === 2){
            return chartProps.series;
        }
        if(!this.state.selectedSubItem){
            if(chartProps?.series?.length){
                this.setState({
                    selectedSubItem:  chartProps.series[0].prefix
                });
            }
            return [];
        }
        const selectedSubItem = this.state.selectedSubItem;
        return chartProps.series.filter(ser => {
            return ser.prefix === selectedSubItem
        });
    }
}