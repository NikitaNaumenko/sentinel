//
import ApexCharts from "apexcharts";

const UptimeMonitorChart = {
  mounted() {
    console.log(this.el);
    console.log("JOPA");

    var options = {
      chart: {
        type: "area",
        stroke: {
          curve: "smooth",
        },
      },
      series: [
        {
          name: "sales",
          data: [30, 40, 35, 50, 49, 60, 70, 91, 125],
        },
      ],
      xaxis: {
        categories: [1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999],
      },
    };
    const data = JSON.parse(this.el.dataset.values);
    console.log(data);
    var chart = new ApexCharts(
      document.getElementById("uptime-monitor-chart"),
      options,
    );

    chart.render();
    // console.log(data);
    // new Chart(document.getElementById("uptime-monitor-chart"), {
    //   type: "line",
    //
    //   options: {
    //     plugins: {
    //       decimation: {
    //         enabled: false,
    //         algorithm: "min-max",
    //         sample: "lltb",
    //       },
    //     },
    //   },
    //   data: {
    //     labels: data.map((row) => row.inserted_at),
    //
    //     datasets: [
    //       {
    //         label: "Uptime",
    //         data: data.map((row) => (row.result === "success" ? 1 : 0)),
    //       },
    //     ],
    //   },
    // });
  },
};
export default UptimeMonitorChart;
