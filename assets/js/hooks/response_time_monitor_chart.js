// import Chart from "chart.js/auto";
//
// export default {
//   mounted() {
//     console.log(this.el);
//
//     const data = JSON.parse(this.el.dataset.values);
//     console.log(data);
//
//     new Chart(document.getElementById("response-time-monitor-chart"), {
//       type: "bar",
//       data: {
//         labels: data.map((row) => row.inserted_at),
//         datasets: [
//           {
//             label: "Response time",
//             data: data.map((row) => row.duration),
//           },
//         ],
//       },
//     });
//   },
// };
//
import ApexCharts from "apexcharts";
export default {
  mounted() {
    console.log(this.el);
    console.log("JOPA");

    const data = JSON.parse(this.el.dataset.values);
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
          data: [30, 40, 35, 50, 49, 60, 70, 91, 125],
        },
      ],
      // xaxis: {
      //   categories: [1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999],
      // },
    };
    console.log(data);
    var chart = new ApexCharts(
      document.getElementById("response-time-monitor-chart"),
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
