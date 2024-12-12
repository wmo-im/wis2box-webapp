<template>
    <v-card>

        <v-card-title class="text-center">
            Notifications
        </v-card-title>

        <vue-apex-charts ref="chart" type="bar" height="400" :options="chartOptions" :series="chartSeries">
        </vue-apex-charts>
    </v-card>
</template>

<script>
import { defineComponent, computed } from 'vue';
import { VCard, VCardTitle } from 'vuetify/lib/components/index.mjs';
import VueApexCharts from 'vue3-apexcharts'

export default defineComponent({
    name: 'BarChart',
    props: {
        messages: {
            type: Array,
            required: true
        },
        startDate: {
            type: Date,
            required: true
        },
        endDate: {
            type: Date,
            required: true
        }
    },
    components: {
        VCard,
        VCardTitle,
        VueApexCharts
    },
    setup(props) {

        // Variables

        // Options for the ApexChart bar graph
        const chartOptions = {
            chart: {
                type: 'bar',
                id: 'realtime',
                animations: {
                    enable: true,
                    easy: 'linear'
                },
                toolbar: {
                    show: false
                }
            },
            plotOptions: {
                bar: {
                    borderRadius: 2,
                    columnWidth: '1%',
                    dataLabels: {
                        position: 'top',
                    },
                }
            },
            dataLabels: {
                enabled: true,
                offsetY: -20,
                style: {
                    fontSize: '12px',
                    colors: ["#304758"]
                }
            },
            stroke: {
                curve: 'straight'
            },
            tooltip: {
                x: {
                    format: 'dd MMM HH:mm',
                }
            },
            colors: ['#00BD9D'], // Colour of bars
            xaxis: {
                type: 'datetime',
                min: props.startDate.getTime(),
                max: props.endDate.getTime(),
                title: {
                    text: 'Publish Time in UTC',
                    offsetX: 0,
                    offsetY: 0,
                    style: {
                        fontSize: '12px',
                        fontFamily: 'Roboto',
                        fontWeight: 600,
                        cssClass: 'apexcharts-xaxis-title',
                    },
                },
                labels: {
                    format: "dd MMM HH:mm",
                },
                axisBorder: {
                    show: true
                },
                axisTicks: {
                    show: true
                }
            },
            yaxis: {
                min: 0,
                labels: {
                    show: false
                },
                axisBorder: {
                    show: false
                },
                axisTicks: {
                    show: false
                }
            }
        }

        // Methods

        // Round a datetime to the nearest minute, used by updateChartData()
        const roundToNearestMinute = (time) => {
            // Get minutes (in UTC) and seconds of the datetime
            let minutes = time.getUTCMinutes();
            let seconds = time.getSeconds();

            if (seconds >= 30) {
                // Round to the next minute
                time.setMinutes(minutes + 1);
            }
            // As rounded to the nearest minute, set the seconds/ms to 0
            time.setSeconds(0);
            time.setMilliseconds(0);

            return time;
        }

        // Computed

        // This method counts the number of messages per minute 
        // and uses this to produce an [x,y] array that populates the ApexChart
        const chartSeries = computed(() => {
            // console.log("Creating chart data");
            // Count messages per minute and uses this create the chart data
            const timestampCounts = {}

            // For each message, find its publish time, round it
            // to the nearest minute, and add a count to an object
            props.messages.forEach(message => {
                const publishTime = message.pubtime;
                // Group notifications by minute
                const roundedTime = roundToNearestMinute(publishTime);
                if (timestampCounts[roundedTime]) {
                    timestampCounts[roundedTime]++;
                } else {
                    timestampCounts[roundedTime] = 1;
                }
            });

            // Convert the timestampCounts object to an array of arrays
            const chartData = Object.entries(timestampCounts)

            // Sort chartData by time, with early entries being more recent
            chartData.sort((a, b) => a[0] - b[0]);

            // Return chart series to be used in ApexChart
            return [
                {
                    name: "WIS2 Notifications Published",
                    data: chartData
                }
            ];
        })

        return {
            chartOptions,
            chartSeries
        }
    }
})

</script>