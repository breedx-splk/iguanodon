import React, {Component} from 'react';
import Chartist from 'chartist';
import Title from './Title';
import Subselect from './Subselect';
import Paper from "@material-ui/core/Paper";
require('chartist-plugin-legend');

export default class Chart extends Component {

    constructor(props){
        super(props);
        this.state = {
        };
    }

    render() {
        const title = this.props.chartProps.title;
        const chartProps = this.props.chartProps;

        const subsel = this.buildSubsel()
        const seriesData = this.buildSeriesData(chartProps);
        const data = {
            labels: chartProps.labels,
            series: seriesData
        };
        const legendContainer = document.getElementById('legend')
        if(legendContainer) legendContainer.innerHTML = ""; // hacky hack
        const options = {
            low: 0,
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0.4
            }),
            position: 'bottom',
            fullWidth: true,
            plugins: [
                Chartist.plugins.legend({
                    position: legendContainer
                })
            ]
        }
        if(data.labels){
            const chart = new Chartist.Line('#chart', data, options);
        }

        return (
            <Paper>
                <Title>{title}</Title>
                {subsel}
                <div id='chart' className="ct-chart ct-perfect-fourth">
                </div>
            </Paper>
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
        const selectedItem = this.chooseSelectedItem();
        return <Subselect chartProps={chartProps} radioChanged={x => this.radioSelChanged(x)} selectedItem={selectedItem}/>
    }

    chooseSelectedItem() {
        const chartProps = this.props.chartProps;
        if(chartProps.prefixes.includes(this.state.selectedSubItem)){
            return this.state.selectedSubItem;
        }
        return chartProps.series[0].prefix;
    }

    buildSeriesData(chartProps) {
        if(chartProps?.series?.length === 2){
            return chartProps.series;
        }
        if(!this.state.selectedSubItem){
            if(chartProps?.series?.length === 0){
                console.log("First time in, no data...");
                return [];
            }
        }
        const selectedSubItem = this.chooseSelectedItem();
        return chartProps.series.filter(ser => {
            return ser.prefix === selectedSubItem
        });
    }
}