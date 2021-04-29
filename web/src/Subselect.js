import {Component} from "react";
import {FormControl, FormControlLabel, FormLabel, Radio, RadioGroup} from "@material-ui/core";

export default class Subselect extends Component {

    constructor(props) {
        super(props);
    }

    handleChange(x){
        console.log(`handle change: ${x.target.value}`);
        this.props.radioChanged(x.target.value);
    }

    render() {

        const chartProps = this.props.chartProps;
        const prefixes = [...new Set(chartProps.series.map(ser => ser.prefix))];

        const radioButtons = prefixes.map(
            prefix => <FormControlLabel value={prefix} control={<Radio/>} label={prefix} key={prefix}/>
        );
        const selectedItem = this.props.selectedItem === undefined ? prefixes[0] : this.props.selectedItem;
        return (
            <FormControl component="fieldset">
                <FormLabel component="legend">sub series:</FormLabel>
                <RadioGroup row aria-label="subseries" name="subseries" value={selectedItem} onChange={x => this.handleChange(x)}>
                    {radioButtons}
                </RadioGroup>
            </FormControl>
        );
    }
}
