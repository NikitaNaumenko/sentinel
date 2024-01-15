import Chart from "chart.js/auto";

const data = [
  { year: 2010, count: 10 },
  { year: 2011, count: 20 },
  { year: 2012, count: 15 },
  { year: 2013, count: 25 },
  { year: 2014, count: 22 },
  { year: 2015, count: 30 },
  { year: 2016, count: 28 },
];

export default {
  mounted() {
    console.log(this.el);

    const data = JSON.parse(this.el.dataset.values);
    console.log(data);

    new Chart(document.getElementById("response-time-monitor-chart"), {
      type: "bar",
      data: {
        labels: data.map((row) => row.inserted_at),
        datasets: [
          {
            label: "Response time",
            data: data.map((row) => row.duration),
          },
        ],
      },
    });
  },
};