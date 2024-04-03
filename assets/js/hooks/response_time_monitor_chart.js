import ApexCharts from "apexcharts";
export default {
  mounted() {
    const { time_series, duration_series } = JSON.parse(this.el.dataset.values);
    var options = {
      chart: {
        type: "area",
        stroke: {
          curve: "smooth",
        },
      },
      series: [
        {
          name: "duration",
          data: duration_series,
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
      document.getElementById("response-time-monitor-chart"),
      options,
    );

    chart.render();
  },
};
