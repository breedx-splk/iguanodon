import React, {Component} from 'react';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import ListSubheader from '@material-ui/core/ListSubheader';
import DashboardIcon from '@material-ui/icons/Dashboard';
import DeleteSweep from '@material-ui/icons/DeleteSweep';
import LayersIcon from '@material-ui/icons/Layers';
import AssignmentIcon from '@material-ui/icons/Assignment';
import {HorizontalSplit, Timer} from "@material-ui/icons";
import {Tooltip} from "@material-ui/core";
import List from '@material-ui/core/List';

export default class LeftNavMenu extends Component {
    render() {
        const updater = this.props.chartUpdater;
        return (
            <List>
                <div>
                    <Tooltip title="Allocation" placement={"bottom-end"}>
                        <ListItem button onClick={() => updater.showAllocations() }>
                            <ListItemIcon>
                                <DashboardIcon/>
                            </ListItemIcon>
                            <ListItemText primary="Allocations"/>
                        </ListItem>
                    </Tooltip>
                    <Tooltip title="Garbage collection" placement={"bottom-end"}>
                        <ListItem button onClick={() => updater.showGarbageCollection() }>
                            <ListItemIcon>
                                <DeleteSweep/>
                            </ListItemIcon>
                            <ListItemText primary="Garbage collection"/>
                        </ListItem>
                    </Tooltip>
                    <Tooltip title="Heap usage" placement={"bottom-end"}>
                        <ListItem button onClick={() => updater.showHeapUsage()}>
                            <ListItemIcon>
                                <HorizontalSplit/>
                            </ListItemIcon>
                            <ListItemText primary="Heap usage"/>
                        </ListItem>
                    </Tooltip>
                    <Tooltip title="Throughput" placement={"bottom-end"}>
                        <ListItem button onClick={() => updater.showThroughput()}>
                            <ListItemIcon>
                                <LayersIcon/>
                            </ListItemIcon>
                            <ListItemText primary="Throughput"/>
                        </ListItem>
                    </Tooltip>
                    <Tooltip title="Startup time" placement={"bottom-end"}>
                        <ListItem button onClick={() => updater.showStartupTime()}>
                            <ListItemIcon>
                                <Timer/>
                            </ListItemIcon>
                            <ListItemText primary="Startup time"/>
                        </ListItem>
                    </Tooltip>
                </div>
            </List>
        );
    }
}