import React, {Component} from 'react';
import Chartist from 'chartist';
import Title from './Title';

export default class Chart extends Component {

    constructor(props){
        super(props);
    }

    render() {
        const title = this.props.chartProps.title;
        const chartProps = this.props.chartProps;

        console.log(`chart sees: `)
        console.log(this.props.chartProps);

        const data = {
            labels: chartProps.labels,
            series: chartProps.series
        };
        const options = {
            low: 0,
            lineSmooth: Chartist.Interpolation.cardinal({
                tension: 0.4
            })
        }
        const chart = new Chartist.Line('#chart', data, options);

        return (
            <React.Fragment>
                <Title>{title}</Title>
                <div id='chart' className="ct-chart ct-perfect-fourth">
                </div>
            </React.Fragment>
        );
    }
}