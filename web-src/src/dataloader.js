
export function fetchAllocations() {
    const url = 'https://breedx-splk.github.io/iguanodon/web/results/allocations.csv';
    return doFetchAndConvert(url);
}

export function fetchGarbageCollection(){
    const url = 'https://breedx-splk.github.io/iguanodon/web/results/garbage_collection.csv';
    return doFetchAndConvert(url);
}

export function fetchStartupTime() {
    const url = 'https://breedx-splk.github.io/iguanodon/web/results/start_time.csv';
    return doFetchAndConvert(url);
}

export function fetchResponseTime() {
    const url = 'https://breedx-splk.github.io/iguanodon/web/results/response_time.csv';
    return doFetchAndConvert(url);
}

export function fetchHeap() {
    const url = 'https://breedx-splk.github.io/iguanodon/web/results/heap_used.csv';
    return doFetchAndConvert(url);
}

function doFetchAndConvert(url){
    return fetch(url)
        .then(response => response.text())
        .then(bodyToChartProps);
}

function bodyToChartProps(body){
    const lines = body.trim().split('\n');
    const fields = lines.shift().split(',');
    const lineCols = lines.map(line => line.split(','));
    const labels = lineCols.map(c => c[0]);
    const series = [...Array(fields.length - 1).keys()]
        .map(index => [index, lineCols.map(c => c[index + 1])])
        .map(series => ({
            name: fields[series[0]+1],
            data: series[1].map(parseFloat)
        }));
    return {
        labels: labels,
        fields: fields,
        series: series
    }
}
