import ApexCharts from "apexcharts";

const UptimeMonitorChart = {
  mounted() {
    const { time_series, result_series } = JSON.parse(this.el.dataset.values);
    var options = {
      chart: {
        type: "area",
        stroke: {
          curve: "smooth",
        },
      },
      dataLabels: {
        enabled: false,
      },
      yaxis: { min: 0, max: 1, stepSize: 1 },
      series: [
        {
          name: "uptime",
          data: result_series,
        },
      ],
      xaxis: {
        labels: {
          show: true,
          datetimeUTC: true,
        },
        type: "datetime",
        categories: time_series,
      },
    };
    var chart = new ApexCharts(
      document.getElementById("uptime-monitor-chart"),
      options,
    );

    chart.render();
  },
};
export default UptimeMonitorChart;
