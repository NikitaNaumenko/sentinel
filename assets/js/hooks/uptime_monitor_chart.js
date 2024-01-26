// import Chart from "chart.js/auto";
//
// const data = [
//   { year: 2010, count: 10 },
//   { year: 2011, count: 20 },
//   { year: 2012, count: 15 },
//   { year: 2013, count: 25 },
//   { year: 2014, count: 22 },
//   { year: 2015, count: 30 },
//   { year: 2016, count: 28 },
// ];
//
// const UptimeMonitorChart = {
//   mounted() {
//     console.log(this.el);
//
//     const data = JSON.parse(this.el.dataset.values);
//     console.log(data);
//     new Chart(document.getElementById("uptime-monitor-chart"), {
//       type: "line",
//
//       options: {
//         plugins: {
//           decimation: {
//             enabled: false,
//             algorithm: "min-max",
//             sample: "lltb",
//           },
//         },
//       },
//       data: {
//         labels: data.map((row) => row.inserted_at),
//
//         datasets: [
//           {
//             label: "Uptime",
//             data: data.map((row) => (row.result === "success" ? 1 : 0)),
//           },
//         ],
//       },
//     });
//   },
// };
// export default UptimeMonitorChart;
